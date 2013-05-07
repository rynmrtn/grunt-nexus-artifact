
module.exports = (grunt) -> class NexusArtifact

	_ = grunt.util._

	# If an ID string is provided, this will return a config object suitable for creation of a NexusArtifact object
	@fromString = (idString) ->
		config = {}
		[config.group_id, config.name, config.ext, config.version] = idString.split(':')
		return config

	constructor: (config) ->
		{@url, @base_path, @repository, @group_id, @name, @version, @ext, @versionPattern} = config

	buildUrl: () ->
		_.compact(_.flatten([
			@url
			@base_path
			@repository
			@group_id.split('.')
			@name
			@buildArtifactUri()
		])).join('/')

	buildArtifactUri: () ->
		@versionPattern.replace /%([ave])/g, ($0, $1) =>
			{ a: @name, v: @version, e: @ext}[$1]