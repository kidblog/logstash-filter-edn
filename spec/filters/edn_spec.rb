# encoding: utf-8
require_relative '../spec_helper'
require "logstash/filters/edn"

describe LogStash::Filters::EDN do
  # Parses an event's source and puts the parsed data on the top level if no
  # :target
  describe "parse EDN into event" do
    config <<-CONFIG
      filter {
        edn {
          # Parse message as edn
          source => "message"
        }
      }
    CONFIG

    sample '{:hello "world", "list" [1 2 3], :map { "foo" "bar" }, 1 "one cookie"}' do
      #debugger
      insist { subject.get("hello") } == "world"
      insist { subject.get("list").to_a } == [1,2,3]
      insist { subject.get("map") } == { "foo"=>"bar" }
      insist { subject.get("1") } == "one cookie"
    end
  end

  # Puts the parsed data under :target if specified
  # Throws an error if passed non-map data and no :target spec'd
  describe "Put parsed EDN into target field" do
    config <<-CONFIG
      filter {
        edn {
          # Parse message as edn
          source => "message"
          target => "edn"
        }
      }
    CONFIG

    sample '{:hello "world"}' do
      insist { subject.get("edn") } == LogStash::Json.load('{"hello":"world"}')
    end
  end

  # Throws an error if passed non-map data and no :target spec'd
  describe "Put parsed EDN into target field" do
    config <<-CONFIG
      filter {
        edn {
          # Parse message as edn
          source => "message"
        }
      }
    CONFIG

    sample '{:hello}' do
      expect(subject.get('tags')).to include("_ednparsefailure")
    end
  end

  # Throws an error if passed non-map data and no :target spec'd
  # except not if :skip_on_invalid_edn
  describe "Put parsed EDN into target field" do
    config <<-CONFIG
      filter {
        edn {
          # Parse message as edn
          source => "message"
          skip_on_invalid_edn => true
        }
      }
    CONFIG

    sample '{:hello}' do
      expect(subject.get('tags')).to be_nil
    end
  end
end

# vim: set et ts=2 sw=2 :
