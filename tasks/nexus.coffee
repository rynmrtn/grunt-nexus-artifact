"use strict"
Q = require 'q'

module.exports = (grunt) ->
	NexusArtifact = require('../lib/nexus-artifact')(grunt)
	util = require('../lib/util')(grunt)

	# shortcut to underscore
	_ = grunt.util._

	grunt.registerMultiTask 'nexus', 'Download an artifact from nexus', ->
		done = @async()

		# defaults
		options = _.extend
			url: ''
			base_path: 'nexus/content/repositories'
			repository: ''
			versionPattern: '%v/%a-%v.%e'
		, @options()

		processes = []

		if !@args.length or @args.indexOf('fetch') > -1
			_.each options.fetch, (cfg) ->
				# get the base nexus path
				_.extend cfg, NexusArtifact.fromString(cfg.id) if cfg.id

				_.extend cfg, options

				artifact = new NexusArtifact cfg

				processes.push util.download(artifact, cfg.path)

		Q.all(processes).then(() ->
			done()
		).fail (err) ->
			grunt.fail.warn err