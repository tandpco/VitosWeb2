require 'securerandom'

class SessionViewController
    public

    def self.createSession(data,session)
        return {:sessionId=>session.id}
    end

    def self.get(key,session)
        return $session[session.id+"--"+key.to_s].to_s
    end

    def self.set(key,value,session)
        $session[session.id+"--"+key.to_s] = value.to_s
        return value.to_s
    end
    
end
