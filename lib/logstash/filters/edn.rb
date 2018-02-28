# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "logstash/json"
require "edn"
require "json"

# This is an EDN parsing filter which takes an existing field containing EDN
# and expands it into a data structure within the Logstash event. It takes a
# lot of inspiration from the JSON filter.
#
# By default, it will place the parsed EDN in the root of the Logstash event,
# but you can specify any arbitrary event field using the `target`
# configuration option.
#
# 
class LogStash::Filters::EDN < LogStash::Filters::Base

  config_name "edn"

  # The configuration options for the EDN filter:
  # [source, ruby]
  #     source => source_field, required
  #     target => target_field, optional
  #
  # Which field contains the EDN data?
  # [source, ruby]
  # -------------------------------
  # filter {
  #   edn {
  #     source => "message"
  #   }
  # }
  # -------------------------------
  config :source, :validate => :string, :required => true

  # Where should we store the parsed data? If this setting is omitted, the EDN
  # data will be store at the top level of the event.
  #
  # NB: This is required if the EDN data isn't a map
  #
  # [source, ruby]
  # -------------------------------
  # filter {
  #   edn {
  #     source => "message"
  #     target => "edn"
  #   }
  # }
  # -------------------------------
  #
  # NB: The `target` field will be overwitten if it exists
  config :target, :validate => :string

  # Array of values to append to the event tags upon parsing failure
  config :tag_on_failure, :validate => :array, :default => [ "_ednparsefailure" ]

  # Should we pass the event through without error/tagging upon parsing failure?
  config :skip_on_invalid_edn, :validate => :boolean, :default => false

  public
  def register
    # This space intentionally empty
  end

  public
  def filter(event)

    @logger.debug? && @logger.debug("Running EDN filter", :event => event)

    # Let's grab the field we're parsing; bail if it's not there
    source = event.get(@source)
    return unless source

    begin
      # Since ES needs this in JSON, we're going to first parse the EDN to Ruby
      # values, then into JSON values
      parsed = LogStash::Json.load(EDN.read(source).to_json)
    rescue Exception => e
      unless @skip_on_invalid_edn
        @tag_on_failure.each{|tag| event.tag(tag)}
        @logger.warn("Error parsing edn", :source => @source, :raw => source, :exception => e)
      end
      return
    end

    # The user told us where they'd like the data, so let's put it there
    if @target
      event.set(@target, parsed)
    else
      # If we don't have a hash, then we don't have keys to tie the values to.
      # We could guess about the key to tie them to, but instead we'll just
      # force people to specify one.
      unless parsed.is_a?(Hash)
        @tag_on_failure.each{|tag| event.tag(tag)}
        @logger.warn("Non-map EDN values require a :target to be specified; exiting EDN filter.", :source => @source, :raw => source)
        return
      end

      # Persist every parsed field into the event
      # JSON doesn't have Symbol/Keyword types, so we convert them to JSON.
      parsed.each{|k, v| event.set(k, v)}
    end

    @logger.debug? && @logger.debug("Event post EDN filtering", :event => event)

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::Edn

# vim: set et ts=2 sw=2 :
