# frozen_string_literal: true

module Capistrano
  module ASG
    module Rolling
      # AWS EC2 Machine Image.
      class AMI
        include AWS

        attr_reader :id, :instance

        def initialize(id, instance = nil)
          @id = id
          @instance = instance
        end

        # Create an AMI from an instance and wait until the AMI is available.
        def self.create(instance:, name:, description: nil, tags: nil)
          aws_ec2_client = instance.aws_ec2_client

          options = {
            instance_id: instance.id,
            name: name,
            description: description
          }

          if tags
            options[:tag_specifications] = tags.flat_map do |key, value|
              [
                { resource_type: 'image', tags: [{ key: key, value: value }] },
                { resource_type: 'snapshot', tags: [{ key: key, value: value }] }
              ]
            end
          end

          response = aws_ec2_client.create_image(options)

          begin
            aws_ec2_client.wait_until(:image_available, image_ids: [response.image_id])
          rescue Aws::Waiters::Errors::TooManyAttemptsError
            # When waiting for the AMI takes longer than the default (10 minutes),
            # then assume it will eventually succeed and just continue.
          end

          new(response.image_id, instance)
        end

        def exists?
          aws_ec2_image.exists?
        end

        def delete
          # Retrieve the snapshots first because we can't call #describe_images anymore
          # after deregistering the image.
          image_snapshots = snapshots

          aws_ec2_client.deregister_image(image_id: id)

          image_snapshots.each(&:delete)
        end

        def snapshots
          @snapshots ||= aws_ec2_image.block_device_mappings.map do |mapping|
            Snapshot.new(mapping.ebs.snapshot_id)
          end
        end

        private

        def aws_ec2_image
          @aws_ec2_image ||= ::Aws::EC2::Image.new(id, client: aws_ec2_client)
        end
      end
    end
  end
end
