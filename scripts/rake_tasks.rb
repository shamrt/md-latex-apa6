class RakeTasks
    def self.write_sources_to(master_file, sources, source_dir="./")
        sources.each do |source|
            if source.is_a? String
                file_path = File.join(source_dir, source)
                # Ensure separation between files
                file_text = File.read(file_path) + "\n\n"
                master_file.write file_text
            elsif source.is_a? Hash
                new_source_dir = File.join(source_dir, source.keys[0])
                new_sources = source.values[0]
                self.write_sources_to(master_file, new_sources, new_source_dir)
            end
        end
    end

    def self.merge(sources_file, output_file)
        master_file = File.new(output_file, mode='w')

        text_sources = File.open(sources_file, mode='r') { |f| YAML.load(f)}
        sources_dir = File.dirname(sources_file)

        self.write_sources_to(master_file, text_sources, sources_dir)

        master_file.close
    end
end
