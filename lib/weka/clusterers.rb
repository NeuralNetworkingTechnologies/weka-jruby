Weka.require_all :clusterers

require 'weka/class_builder'

module Weka
  module Clusterers
    include ClassBuilder

    build_classes :Canopy,
                  :Cobweb,
                  :EM,
                  :FarthestFirst,
                  :FilteredClusterer,
                  :HierarchicalClusterer,
                  :MakeDensityBasedClusterer,
                  :SimpleKMeans
  end
end
