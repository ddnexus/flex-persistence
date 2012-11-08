module Flex
  module Persistence
    module Storage

      module ClassMethods

        def create(args={})
          document = new(args)
          return false unless document.valid?
          document.save
          document
        end

      end


      module InstanceMethods

        def reload
          document        = flex.get
          self.attributes = document['_source']
          @_id            = document['_id']
          @_version       = document['_version']
        end

        def save(vars={})
          return false unless valid?
          run_callbacks :save do
            self.created_at = DateTime.now if respond_to?(:created_at) && new_record?
            self.updated_at = DateTime.now if respond_to?(:updated_at)
            result    = flex.store(vars)
            @_id      = result['_id']
            @_version = result['_version']
          end
          self
        end

        # Optimistic Lock Update
        #
        #    doc.lock_update do |d|
        #      d.amount += 100
        #    end
        #
        # if you are trying to update a stale object, the block is yielded again with a fresh reloaded document and the
        # document is saved only when it is not stale anymore (i.e. the _version has not changed since it has been loaded)
        # read: http://www.elasticsearch.org/blog/2011/02/08/versioning.html
        #
        def lock_update(vars={})
          return false unless valid?
          run_callbacks :save do
            begin
              yield self
              result = flex.store({:params => {:version => _version}}.merge(vars))
            rescue Flex::HttpError => e
              if e.status == 409
                reload
                retry
              else
                raise
              end
            end
            @_id      = result['_id']
            @_version = result['_version']
          end
          self
        end

        def destroy
          run_callbacks :destroy do
            flex.remove
            @destroyed = true
          end
          self.freeze
        end

        def destroyed?
          !!@destroyed
        end

        def persisted?
          !!id && !!_version
        end

        def new_record?
          !persisted?
        end

      end

    end


  end
end
