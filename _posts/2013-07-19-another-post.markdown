---
layout: post
title:  "Some other title that is bigger"
date:   2013-07-19 00:00:28
tags:   update something
summary: Just something else so I can see how summaries behave in my new layout.
---

You'll find this post in your `_posts` directory - edit this post and re-build (or run with the `-w` switch) to see your changes!
To add new posts, simply add a file in the `_posts` directory that follows the convention: YYYY-MM-DD-name-of-post.ext.

<!--more-->

Jekyll also offers powerful support for code snippets:

 * bla
    1. sub 1
    2. Sub 2
 * ads
    * sub 1
    * sub 2

{% highlight ruby %}
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
{% endhighlight %}

> Some sort of a citation
>
> With many lines & stuff. Know what I "mean", man?
> 
> <cite> Rodrigo Dumont [^1]</cite>


Check out the [Jekyll docs][jekyll] for more info on how to get the most out of Jekyll. File all bugs/feature requests at [Jekyll's GitHub repo][jekyll-gh].

[jekyll-gh]: https://github.com/mojombo/jekyll
[jekyll]:    http://jekyllrb.com


## Some C# Code ## {#das}

{% highlight csharp %}
public class Foo
{
    public void Bar(string word)
    {
        Console.WriteLine("Hello {0}!", word);
    }
}
{% endhighlight %}

{% highlight http %}
GET api/post/bla HTTP/1.0
{% endhighlight %}

{% highlight gherkin %}
Feature: some-feature

Scenario: Do something
    Given bla
    When lada
    Then ok!
{% endhighlight %}

---

## References

[^1]: http://rodrigodumont.com
