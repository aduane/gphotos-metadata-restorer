def fix_file_metadata(file, metadata_file)
  # now that we've identified the correct metadata file, we should read the
  # data from it and ensure the correct tags are set on the file.

end

Dir.glob('/Users/personal/Downloads/photos/Takeout/Google Photos/*').select {|f| File.directory? f}.each do |photo_directory|
  Dir.glob("#{photo_directory}/*").each do |absolute_filepath|
    filename = absolute_filepath.split('/')[-1]
    file_extension = filename.split('.')[-1]

    next if ['json', 'html'].include?(file_extension)

    metadata_file = nil
    metadata_candidate = "#{absolute_filepath}.json"

    metadata_files = Dir.glob("#{photo_directory}/*")
    downcased_metadata_files = metadata_files.map(&:downcase)

    # usually we can find the one by looking for the exact path, with '.json'
    # appended
    if downcased_metadata_files.include?("#{absolute_filepath}.json".downcase)
      metadata_file = metadata_candidate

    # Sometimes the metadata is like you'd expect, only there's a character
    # missing from the end of the filepath. WEIRD!
    # EXAMPLE:
    #   'hamburglar_in_love_by_isabellaprice-d6rfq6z.png' (don't judge)
    #   should use the metadata file:
    #   'hamburglar_in_love_by_isabellaprice-d6rfq6z.pn.json' <-- note the
    #   '.pn.json' rather than the expected '.png.json'
    elsif downcased_metadata_files.include?("#{absolute_filepath[0..-2]}.json".downcase)
      metadata_file = "#{absolute_filepath[0..-2]}.json"

    # Similar to the above, sometimes there is a character missing from the
    # end, but it is before the file extension, AND the file extension is
    # replaced by the .json extension rather than appended to. SUPER WEIRD!
    # EXAMPLE:
    #   '1547619445646-f3910eb9-859a-42b0-8bca-d8a34d2bd.jpg' could use the
    #   metadata file:
    #   '1547619445646-f3910eb9-859a-42b0-8bca-d8a34d2b.json' <-- note the
    #   ending '4d2b' rather than the original '4d2bd'
    elsif downcased_metadata_files.include?("#{absolute_filepath.split('.')[0..-2].join[0..-2]}.json".downcase)
      metadata_file = "#{absolute_filepath.split('.')[0..-2].join[0..-2]}.json"

    # In some cases there are duplicates of the file, but with some edit
    # applied. in this case, we try to search for the metadata of the original
    # file by stripping out the edited parts of the filename.
    # EXAMPLE:
    #   'IMG_20130711_123218-edited.jpg' should use the metadata
    #   file: 'IMG_20130711_123218.JPG.json'
    elsif matchdata = /(.*)(?:-SMILE)?-edited(\.[\w\d]+)/i.match(filename)
      metadata_candidate = "#{photo_directory}/#{matchdata[1..2].join}.json"
      if downcased_metadata_files.include?(metadata_candidate.downcase)
        metadata_file = metadata_candidate
      end

    # Same as above, but with a parenthetical number at the end
    # EXAMPLE:
    #   'IMG_20190928_144857-edited(1).jpg' should use the metadata
    #   file: 'IMG_20190928_144857.jpg(1).json'
    elsif matchdata = /(.*)(?:-SMILE)?-edited(\(\d+\))(\.[\w\d]+)/i.match(filename)
      metadata_candidate = "#{photo_directory}/#{matchdata[1]}#{matchdata[3]}#{matchdata[2]}.json"
      if downcased_metadata_files.include?(metadata_candidate.downcase)
        metadata_file = metadata_candidate
      end
      
    # Sometimes the file has a parenthetical number before the file extension
    # that is not present in the metadata. idk why. Note that the '_COV'
    # variant is handled later, and should be excluded from this. This
    # should not exclude _COVER, however.
    # EXAMPLE:
    #   'MVIMG_20180121_183315(1).jpg' should use the metadata
    #   file: 'MVIMG_20180121_183315.jpg.json'
    elsif (matchdata = /(.*)\(\d+\)(\.[\w\d]+)/i.match(filename)) && !(filename.include?('_COV(') || filename.include?('_COV.'))
      metadata_candidate = "#{photo_directory}/#{matchdata[1..2].join}.json"
      if downcased_metadata_files.include?(metadata_candidate.downcase)
        metadata_file = metadata_candidate
      else
        # Sometimes the metadata file does not contain the file extension
        metadata_candidate = "#{photo_directory}/#{matchdata[1]}.json"
        if downcased_metadata_files.include?(metadata_candidate.downcase)
          metadata_file = metadata_candidate
        end
      end

    # Some files end in "(filename string)_COV.(file extension)"
    # For whatever reason, the matching metadata file will be:
    # "(filename string)_CO.json" <-- Not a typo, there is no "V"
    # EXAMPLE:
    #   '00100sPORTRAIT_00100_BURST20190330202705895_COV.jpg' should use
    #   metadata file:
    #   '00100sPORTRAIT_00100_BURST20190330202705895_CO.json'
    elsif matchdata = /(.*)_COV\.[\w\d]+/i.match(filename)
      metadata_candidate = "#{photo_directory}/#{matchdata[1]}_CO.json"
      if downcased_metadata_files.include?(metadata_candidate.downcase)
        metadata_file = metadata_candidate
      end

    # Same as above, but with a parenthetical number at the end
    # EXAMPLE:
    #   '00100dPORTRAIT_00100_BURST20200304175154997_COV(1).jpg' should use
    #   metadata file:
    #   '00100dPORTRAIT_00100_BURST20200304175154997_CO(1).json'
    elsif matchdata = /(.*)_COV(\(\d+\))\.[\w\d]+/i.match(filename)
      metadata_candidate = "#{photo_directory}/#{matchdata[1]}_CO#{matchdata[2]}.json"
      if downcased_metadata_files.include?(metadata_candidate.downcase)
        metadata_file = metadata_candidate
      end

    # Finally, attempt to find a metadata file that matches the exact
    # filepath, but with .json replacing the file extension instead of being
    # appended after it.
    # EXAMPLE:
    #   'c915623f-a98e-4672-b560-0e0e13d3e436.jpg' could use the metadata
    #   file: 'c915623f-a98e-4672-b560-0e0e13d3e436.json'
    else
      metadata_candidate = "#{photo_directory}/#{filename.split('.')[0..-2].join}.json"
      if downcased_metadata_files.include?(metadata_candidate.downcase)
        metadata_file = metadata_candidate
      end
    end

    # the case may not match on the metadata_file, so we should look the the
    # metadata_files and select the properly-cased one that matches the
    # downcased one
    cased_metadata_file = metadata_files.select{|file| file.downcase == metadata_file.downcase}[0]

    # If we didn't find one, say so
    if metadata_file == nil
      puts "*" * 80
      puts "Could not find metadata for: #{absolute_filepath}"
      puts "Here are the metadata files in the directory: "
      puts Dir.glob("#{photo_directory}/*.json").join("\n")
      puts ("*" * 80) + "\n\n"
    else
      fix_file_metadata(absolute_filepath, metadata_file)
    end
  end
end
