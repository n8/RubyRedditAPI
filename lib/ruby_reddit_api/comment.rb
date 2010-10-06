module Reddit
  class Comment < Api
    include JsonListing
    attr_reader :body, :subreddit_id, :name, :created, :downs, :author, :created_utc, :body_html, :link_id, :parent_id, :likes, :replies, :subreddit, :ups, :debug, :kind
    def initialize(json)
      parse(json)
      @debug = StringIO.new
    end

    def inspect
      "<Reddit::Comment author='#{@author}' body='#{short_body}'>"
    end

    def id
      "#{kind}_#{@id}"
    end

    def author
      @author_data ||= read("/user/#{@author}/about.json", :handler => "User")
    end

    def to_s
      body
    end

    def edit(newtext)
      resp=self.class.post("/api/editusertext", {:body => {:thing_id => id, :uh => modhash, :r => subreddit, :text => newtext }, :headers => base_headers, :debug_output => @debug })
      resp.code == 200
    end

    def hide # soft delete?
      resp=self.class.post("/api/del", {:body => {:id => id, :uh => modhash, :r => subreddit, :executed => "removed" }, :headers => base_headers, :debug_output => @debug })
      resp.code == 200
    end

    def remove
      resp=self.class.post("/api/remove", {:body => {:id => id, :uh => modhash, :r => subreddit}, :headers => base_headers, :debug_output => @debug })
      resp.code == 200
    end

    def approve
      resp=self.class.post("/api/approve", {:body => {:id => id, :uh => modhash, :r => subreddit}, :headers => base_headers, :debug_output => @debug })
      resp.code == 200
    end

    def moderator_distinguish
      add_distinction "yes"
    end

    def admin_distinguish
      add_distinction "admin"
    end

    def indistinguish
      add_distinction "no"
    end

    def reply(text)
      resp = self.class.post("/api/comment", {:body => {:thing_id => id, :text => text, :uh => modhash, :r => subreddit }, :headers => base_headers, :debug_output => @debug })
      resp.code == 200
    end

    def upvote
      Vote.new(self).up
    end

    def downvote
      Vote.new(self).down
    end

    def short_body
      str = body.to_s
      if str.size > 15
        str[0..15] + "..."
      else
        body
      end
    end

    def add_distinction(verb)
      resp=self.class.post("/api/distinguish/#{verb}", {:body => {:id => id, :uh => modhash, :r => subreddit, :executed => "distinguishing..."}, :headers => base_headers, :debug_output => @debug })
      puts resp.headers
      resp.code == 200
    end
  end
end