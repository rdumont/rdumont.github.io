---
layout: post
tags: moq unit-tests csharp tdd
date: 2013-09-26 00:15:00
title: Fluent mocking for unit tests
---

If you seriously write **unit tests in C#**, then I'm sure that you have sometimes come to a point where there are just too many, or perhaps too complex mocks in your code. When that happens, you can almost feel yourself giving in to the dark side and using an actual implementation just to avoid all the mess of **setting up mocks**.

<!--more-->

Let's say you had to do something like the following. Maybe you would even choose to write a mock class instead of using our good friend **[Moq](https://github.com/Moq/moq4 "Moq")**.

```csharp
[Test]
void Find_beer_that_harmonizes()
{
    // Arrange
    var beer1 = new Mock<IBeer>();
    beer2.Setup(b => b.HarmonizesWith(It.IsAny<string>)).Returns(false);
    beer1.Setup(b => b.HarmonizesWith("pasta")).Returns(true);
    
    var beer2 = new Mock<IBeer>();
    beer2.Setup(b => b.HarmonizesWith(It.IsAny<string>)).Returns(false);
    beer2.Setup(b => b.HarmonizesWith("cheese")).Returns(true);
    
    var beer3 = new Mock<IBeer>();
    beer3.Setup(b => b.HarmonizesWith(It.IsAny<string>)).Returns(false);
    beer3.Setup(b => b.HarmonizesWith("seafood")).Returns(true);
    
    var beers = new IBeer[] { beer1, beer2, beer3 };
    var harmonizer = new BeerHarmonizer(beers);

    // Act
    var chosenBeer = harmonizer.ChooseBeerByFood("cheese");

    // Assert
    Assert.That(chosenBeer, Is.SameAs(beers[1]));
}
```

Although this may seem like a simple step, it sure is a helpful one. The `Mock.Of<TObject>()` syntax allows us to directly get the mock proxy, instead of having to deal with `myMock.Object`. Now, we can write simple **extension methods** that hide de setup complexity far from sight, but still just one click away. Much cleaner and readable, right?

```csharp
[Test]
void Find_beer_that_harmonizes()
{
    // Arrange
    var beers = new IBeer[]
    {
        Mock.Of<IBeer>().ThatHarmonizesWith("pasta");
        Mock.Of<IBeer>().ThatHarmonizesWith("cheese");
        Mock.Of<IBeer>().ThatHarmonizesWith("seafood");
    };
    var harmonizer = new BeerHarmonizer(beers);

    // Act
    var chosenBeer = harmonizer.ChooseBeerByFood("cheese");

    // Assert
    Assert.That(chosenBeer, Is.SameAs(beers[1]));
}
```

Below is the actual extension method.

```csharp
public static IBeer ThatHarmonizesWith(this IBeer beer, string food)
{
    var mock = Mock.Get(beer);
    mock.Setup(b => b.HarmonizesWith(It.IsAny<string>)).Returns(false);
    mock.Setup(b => b.HarmonizesWith(food)).Returns(true);

    return beer;
}
```

I hope this simple tip was helpful to you. Keep TDDing and remember: readability is the key!