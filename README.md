# Rulex

Rulex is a rubygem allowing you to use Ruby while writing LaTex files. It reads rulex `.rex` files, and converts them into LaTex `.tex` files. A `.rex` file is a Ruby file; you can use (almost) everything the way you would in a Ruby script. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rulex'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rulex

## Usage

**Everything is still very experimental, and might break at any point!**

*For detailed documentation, please refer to the code, mainly `/spec/rulex_spec.rb`. There are a few examples as well in `/examples/`.*


### Example 

```ruby
# example.rex
documentclass :article

def count_from range
  first = range.first
  last = range.last

  subsection "how to count from #{first} to #{last}"
  raw "Let's try to count."

  itemize do
    range.each do |n|
      item n.to_s
    end
  end
end
document do
  section "A Short Lecture on How to Count"

  count_from (1..5)
  count_from (10..20)

  raw "Good job, now off to section "; ref :acks;

  section "Acknowledgements"
  label :acks

  raw "Finally I would like to thank \n"

  enumerate do
    %w[Donald\ Knuth Yukihiro\ Matsumoto].each do |name|
      item "Mr. #{name}"
    end
  end
end
```

Run `rulex example.rex > example.tex` to get

```latex
% example.tex
\documentclass{article}
\begin{document}
\section{A Short Lecture on How to Count}
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
\end{document}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/Nicowcow/rulex/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


### What can I do?

* `Rulex::Tex::Grammar::Document` is a big misnommer! It should be changed to something that reflects better what its role is.
* `Rulex::Rex::Reader#raw` might not be the best name either. Maybe change it to text.
* Add markdown support to `Rulex::Rex::Reader` through Pandoc
* The parser needs some beefin-up (not sure what it does with spaces, especially with command options)
* Maybe add some syntax for LaTeX commands to output text directly rather than store the command in the tree
