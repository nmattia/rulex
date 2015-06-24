# First thing to note, your rex file must follow the TeX document structure. You will start
# with a `\documentclass` call, then wrap your document in a `document` environment by calling `\begin{document}` and `\end{document}`. The only difference here is that most of this process is wrapped in Ruby.


# Just call `documentclass` to set the document class. This for instance will be translated to `\documentclass{article}`.
documentclass :article 

# You can define your own Ruby functions.
def count_from range
  first = range.first
  last = range.last

# Any function call, like `functionname("arg1", "arg2",...)`, will be translated to `\functionname{arg1}{arg2}{...}`. 
# That way, you can start a subsection as follows:
  subsection "how to count from #{first} to #{last}"

# Raw is a special `rex` function. It writes its argument as text in the rex tree (and subsequently in the TeX file) without parsing it. Note that the fact that it is not writing a `\raw` function is exceptional, because `raw` is a `rex` reserved function name. To use `raw` like you would use `subsection` call `tex_command :raw`.
  raw "Let's try to count."

# If you pass a command a bloc, it will start a TeX environment. The following `itemize do ... end` is equivalent to `\begin{itemize} ... \end{itemize}`.
  itemize do
    range.each do |n|
      item n.to_s
    end
  end
end

document do
  section "A Short Lecture on How to Count"


# You can of course call the functions you defined (AND NOT BE LIMITED TO 9 ******* ARGUMENTS)

  count_from (1..5)
  count_from (10..20)

  # At any time, you can prefix a method call with `pure_`. This will return the LaTeX text
  # (`String`) that would have been produced, instead of writing the command to the
  # document tree. For instance, we want to write the whole text "Good job, ... " to the
  # document tree, while referencing the next section; we don't want to write it to the 
  # tree on top of that!
  raw "Good job, now off to section #{pure_ref :acks}\n" 

  section "Acknowledgements"
  label :acks

  raw "Finally I would like to thank \n"

  enumerate do
# You can of course use just any kind of Ruby goodness you like.
    %w[Donald\ Knuth Yukihiro\ Matsumoto].each do |name|
      item "Mr. #{name}"
    end
  end
end
