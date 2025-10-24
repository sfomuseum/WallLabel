# https://github.com/ml-explore/mlx-swift?tab=readme-ov-file#xcodebuild

macos:
	xcodebuild build -scheme wall-label -destination 'platform=OS X' EXCLUDED_SOURCE_FILE_NAMES="Parser_FoundationModel.swift,WallLabel_Generable.swift"

macos-tahoe:
	xcodebuild build -scheme wall-label -destination 'platform=OS X' 
