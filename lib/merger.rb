require 'psych'
require 'java'
java_import 'MergeAccelerator'
class Merger
   attr_accessor :config
   def initialize db
      @db = db
      @msplitter = Splitter::MergeSplitter.new db
      @config = [{'fields' => 'all', 'weight' => 1}]
   end

   def score_records record, other
      points_possible = 0
      rule_scores = @config.map do |rule|
         weight = rule['weight']
         fields = rule['fields']
         if fields == 'all'
            fields = record.keys
         end

         rule_total = rule_total fields, weight, record, other

         if rule_total
            # Add the rule's weight to the points possible
            points_possible += weight
            # Return the score for the rule
            rule_total/fields.length.to_f
         else
            # A field was nil
            # Don't add the rule's weight
            # Return 0 to not change the sum
            0
         end
      end

      total_points = rule_scores.reduce(0, :+)
      total_points/points_possible
   end

   def rule_total fields, weight, record, other
      scores = fields.map do |field|
         val1 = record[field]
         val2 = other[field]

         if val1.nil? or val2.nil?
            return nil
         end

         edit_dist(weight, val1, val2)
      end
      scores.reduce(0, :+)
   end

   ## Returns a value between 0 and 1, with 0 being completely
   #dissimilar, and 1 being identical
   def edit_dist weight, val1, val2
      # TODO: Real edit distance
      val1 == val2 ? weight : 0
   end

   def score_pair key, val1, val2
      default = 1
      if @scores.key? key
         if val1==val2
            @scores[key]
         end
      else
         if val1 == val2
            default
         end
      end
   end

   def merge_records first, second
      # TODO Really merge record
      merged = first
      merge_reason = "merge duplicate records"

      @msplitter.insert_merged_record merged
      first[:mId] = second[:mId] = merged[:mId]

      @msplitter.insert_contrib_record first, merge_reason
      @msplitter.insert_contrib_record second, merge_reason
   end

   def match_record record, records
      high_score = 0
      pair = nil

      threads = []
      records.split(15) do |hunk|
         threads << Thread.new do
            hunk.each do |other|
               score = score_records record, other
               if score > 0.5 and high_score < score
                  high_score = score
                  pair = other
               end
            end
         end
      end
      threads.map {|thr| thr.join}
      pair
   end

   def match_record_list list
      count = 0
      list.each_with_index do |record, i|
         pair = match_record record, list[i+1..-1]
         if pair
            merge_records record, pair
         else
            @msplitter.insert_new_merge record
         end
         count += 1
         puts "#{count} records merged"
      end
      count
   end
end

class Array
   def split n
      max = length

      i = 0
      while i+n < max
         yield self[i..i+n]
         i += n
      end

      if i < max
         yield self[i..-1]
      end
   end
end
