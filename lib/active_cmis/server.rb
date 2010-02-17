module ActiveCMIS
  # This class is used to manage different CMIS servers.
  class Server
    attr_reader :endpoint

    # A connection needs the URL to a CMIS REST endpoint.
    #
    # It's used to manage all communication with the CMIS Server
    def initialize(endpoint)
      @endpoint = endpoint
    end

    # Use authentication to access the CMIS repository
    #
    # e.g.: repo.authenticate(:basic, "username", "password")
    def authenticate(method, *params)
      conn.authenticate(method, *params)
    end

    # Returns the _Repository identified by the ID
    def repository(repository_id)
      repository_data = repository_info.xpath("/app:service/app:workspace[cra:repositoryInfo/c:repositoryId[child::text() = '#{repository_id}']]", NS::COMBINED)
      Repository.new(conn.dup, repository_data)
    end

    # Lists all the available repositories
    #
    # Returns an Array of Hashes containing :id and :name
    def repositories
      repositories = repository_info.xpath("/app:service/app:workspace/cra:repositoryInfo", NS::COMBINED)
      repositories.map {|ri| next {:id => ri.xpath("ns:repositoryId", "ns" => NS::CMIS_CORE).text,
        :name => ri.xpath("ns:repositoryName", "ns" => NS::CMIS_CORE).text }}
    end

    private
    def repository_info
      @repository_info ||= Nokogiri.parse(conn.get(endpoint))
    end

    def conn
      @conn ||= Internal::Connection.new
    end
  end
end