module PGHelper
    def self.connect(conf)
        Gem.clear_paths
        require 'rubygems'
        require 'pg'
        conn = ::PG.connect conf
        begin
            yeild conn
        ensure
            conn.close
        end
    end
end
