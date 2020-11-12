
class User
	include DataMapper::Resource

	property :Username, String , :key => true  # Cannot be null
	property :password, String
end


DataMapper.finalize
