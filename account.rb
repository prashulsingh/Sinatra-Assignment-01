
class Account
	include DataMapper::Resource

	property :username, String, :key => true
	property :totalwin, Integer
	property :totalloss, Integer
	property :totalprofit, Integer
end


DataMapper.finalize
