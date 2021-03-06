require_relative 'licensee/version'
require 'forwardable'
require 'pathname'
require 'rugged'

module Licensee
  autoload :ContentHelper, 'licensee/content_helper'
  autoload :License, 'licensee/license'
  autoload :Rule, 'licensee/rule'
  autoload :Matchers, 'licensee/matchers'
  autoload :Projects, 'licensee/projects'
  autoload :ProjectFiles, 'licensee/project_files'

  # Over which percent is a match considered a match by default
  CONFIDENCE_THRESHOLD = 98

  # Base domain from which to build license URLs
  DOMAIN = 'http://choosealicense.com'.freeze

  class << self
    attr_writer :confidence_threshold

    # Returns an array of Licensee::License instances
    def licenses(options = {})
      Licensee::License.all(options)
    end

    # Returns the license for a given path
    def license(path)
      Licensee.project(path).license
    end

    def project(path, **args)
      Licensee::Projects::GitProject.new(path, args)
    rescue Licensee::Projects::GitProject::InvalidRepository
      Licensee::Projects::FSProject.new(path, args)
    end

    def confidence_threshold
      @confidence_threshold ||= CONFIDENCE_THRESHOLD
    end

    # Inverse of the confidence threshold, represented as a float
    # By default this will be 0.05
    def inverse_confidence_threshold
      @inverse ||= (1 - Licensee.confidence_threshold / 100.0).round(2)
    end
  end
end
