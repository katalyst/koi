module Koi
  class AdminCrudController < Koi::ApplicationController
    helper :all
    has_crud :admin => true
    defaults :route_prefix => 'admin'

  protected

    # Matches missing route methods of the form (action_)?koi_(controller)_path,
    # and sends them to koi_engine instead.
    # 
    # This is necessary because inherited_resources is resolving paths differently
    # depending on whether they belong to the koi_engine or not.
    #
    def method_missing key, *sig, &blk
      if match = /(\w+_|\b)koi_(\w+)_path$/.match(key)
        prefix, suffix = match.to_a.drop 1
        koi_engine.send :"#{ prefix }#{ suffix }_path", *sig, &blk
      else
        super
      end
    end
       
  end
end
