module Ms1to2
	extend ActiveSupport::Autoload
	autoload :CSVParser
	autoload :Importer
	autoload :UserImporter
	autoload :Normalizer
	autoload :UserNormalizer
	autoload :Ms1BatchFileConverter
	autoload :Ms1InputData
	autoload :Ms2OutputData
end