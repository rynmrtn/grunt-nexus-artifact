http = require 'http'
fs = require 'fs'
Q = require 'q'

module.exports = (grunt) ->

	downloadFile = (artifact, path, temp_path) ->
		deferred = Q.defer()

		grunt.util.spawn(
			cmd: 'curl'
			args: "-o #{temp_path} #{artifact.buildUrl()}".split(' ')
		, (err, stdout, stderr) ->
			if err
				deferred.reject err
				return

			grunt.util.spawn(
				cmd: 'tar'
				args: "zxf #{temp_path} -C #{path}".split(' ')
			,
				(err, stdout, stderr) ->

					grunt.file.delete temp_path

					if err
						deferred.reject err
						return

					grunt.file.write "#{path}/.version", artifact.version

					deferred.resolve()
			)
		)

		deferred.promise

	{

		###*
		#* Download an nexus artifact and extract it to a path
		#* @param {NexusArtifact} artifact The nexus artifact to download
		#* @param {String} path The path the artifact should be extracted to
		#*
		#* @return {Promise} returns a Q.defer() promise to be resolved when the file is done downloading
		###
		download: (artifact, path) ->
			deferred = Q.defer()

			return if grunt.file.exists("#{path}/.version") and (grunt.file.read("#{path}/.version").trim() is artifact.version)

			grunt.file.mkdir path

			temp_path = "#{path}/temp.#{artifact.ext}"
			grunt.log.writeln "Downloading #{artifact.buildUrl()}"

			downloadFile(artifact, path, temp_path).then( ->
				deferred.resolve()
			).fail( (error) ->
				deferred.reject(error)
			)

			deferred.promise
	}