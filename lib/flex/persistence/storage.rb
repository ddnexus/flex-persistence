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

        def save(vars={})
          return false unless valid?
          run_callbacks :save do
            result        = flex.store(vars)
            self.id       = result['_id']
            self._version = result['_version']
          end
          self
        end

        def reload
          document        = flex.get
          self.attributes = document['_source']
          self.id         = document['_id']
          self._version   = document['_version']
        end

        # Optimistic Lock Update
        #
        #    doc.lock_update do |d|
        #      d.amount += 100
        #    end
        #
        # the block is potentially yielded many time, with a reloaded document
        # but saved only if the document was not stale (i.e. the _version has not changed since it has been loaded)
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
            self.id       = result['_id']
            self._version = result['_version']
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
