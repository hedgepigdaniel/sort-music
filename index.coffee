MusicMetadata = require 'musicmetadata'
Commander = require 'commander'
fs = require 'fs'
async = require 'async'
path = require 'path'

Commander
	.usage '[options] <file ...>'
	.option('-d, --dest <dest>', 'Destination directory')
	.option('-m, --move', 'Move each track to destination directory instead of making a copy')
	.parse process.argv

processInputPath = (sourcePath, callback) =>
	fs.stat sourcePath, (err, stats) =>
		if err
			callback err
		else if stats.isDirectory()
			fs.readdir sourcePath, (err, subPaths) =>
				if err
					callback "Failed to read directory: " + sourcePath
				else
					for subFile in subPaths
						subFile = path.join sourcePath, subFile
						inputPathQueue.push subFile
					callback null
		else if stats.isFile()
			inputFileQueue.push sourcePath
			callback null

processFile = (filePath, callback) =>
	console.log "Processing file: " + filePath
	fileStream = fs.createReadStream filePath
	MusicMetadata fileStream, (err, metadata) =>
		if err
			console.log "Failed to read metadata for " + filePath
			callback err
		else
			console.log metadata
			callback null

inputPathQueue = async.queue processInputPath, 1
inputFileQueue = async.queue processFile, 1

for sourcePath in Commander.args
	inputPathQueue.push sourcePath