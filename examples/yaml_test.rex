---
data  :
    company_name    :   My Company

pipeline:   
  -  - Rulex::NodeBuilder
     - Rulex::Echo
---

puts "#{data[:company_name]}"

hi
