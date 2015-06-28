# Rulex

![Travis-CI badge](https://api.travis-ci.org/Nicowcow/rulex.svg)
[![Code Climate](https://codeclimate.com/github/Nicowcow/rulex/badges/gpa.svg)](https://codeclimate.com/github/Nicowcow/rulex)
[![Test Coverage](https://codeclimate.com/github/Nicowcow/rulex/badges/coverage.svg)](https://codeclimate.com/github/Nicowcow/rulex/coverage)
[![Inline docs](http://inch-ci.org/github/Nicowcow/rulex.svg?branch=master)](http://inch-ci.org/github/Nicowcow/rulex)

Rulex is a rubygem allowing you to use Ruby while writing LaTex files. It reads rulex `.rex` files, and converts them into LaTex `.tex` files. A `.rex` file is a Ruby file; you can use (almost) everything the way you would in a Ruby script. 

## Installation

To start using Rulex, you'll first need Ruby and Rubygems (here for a Debian-like, though I recommend rvm):

    $ apt-get install ruby && apt-get install rubygems

and then install the gem as 

    $ gem install rulex


To use it in your own project, add this line to your application's Gemfile:

```ruby
gem 'rulex'
```

And then execute:

    $ bundle


## Usage

*For detailed documentation, please refer to the code, mainly `/spec/rulex_spec.rb`. There are a few examples as well in `/examples/`.*

**Everything is still very experimental, and might break at any point!** Consider using a specific version, and sticking to it if it works.



### Example 

```ruby
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

  # You can use markdown (though you need `pandoc` to be installed)
  md "Pay attention, the following is *very* important."

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


# At any time, you can use the delimiters `<##` and `##>` to inject LaTeX code. Note that the following characters won't be escaped: '\\', '\]', '\['.. The delimiters are part of the Rulex file syntax, and are translated into Ruby calls when the file is process; they aren't some kind of Ruby magic. 
  <## \subsection{Some pure \LaTeX}
  
  And some more here.
  
  ##>
end
```

Run `rulex example.rex > example.tex` to get

```latex
\documentclass{article}
\begin{document}
\section{A Short Lecture on How to Count}
Pay attention, the following is \emph{very}
 important.
\subsection{how to count from 1 to 5}
Let's try to count.\begin{itemize}
\item{1}
\item{2}
\item{3}
\item{4}
\item{5}
\end{itemize}
\subsection{how to count from 10 to 20}
Let's try to count.\begin{itemize}
\item{10}
\item{11}
\item{12}
\item{13}
\item{14}
\item{15}
\item{16}
\item{17}
\item{18}
\item{19}
\item{20}
\end{itemize}
Good job, now off to section \ref{acks}

\section{Acknowledgements}
\label{acks}
Finally I would like to thank 
\begin{enumerate}
\item{Mr. Donald Knuth}
\item{Mr. Yukihiro Matsumoto}
\end{enumerate}
 \subsection{Some pure \LaTeX}
  
  And some more here.
  
  \end{document}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

### I want no business with Ruby.

Rulex is very young, and everything is very likely to break down. Just use it, and open an issue if something goes wrong. You can also contact me.

### I want no business with LaTeX.

That's the point. Seriously, the code might need some refactoring, and can always use cool tricks.

1. Fork it ( https://github.com/Nicowcow/rulex/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### What can I do?

* `Rulex::Tex::Grammar::Document` is a big misnommer! It should be changed to something that reflects better what its role is.
* `Rulex::Rex::Reader#raw` might not be the best name either. Maybe change it to text.
* The parser needs some beefin-up (not sure what it does with spaces, especially with command options)
* Coffee is on me if you write a Vim plugin
* Another coffee if you also write a Rake task.
* There should be some special delimiters like Ruby's `#{...}` (maybe `#< ... >`) which would translate all method calls to `pure_` method calls. That would make inlining method calls in strings much easier.
