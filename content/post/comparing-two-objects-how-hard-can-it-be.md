---
author: "Rodrigo Dumont"
date: 2014-10-29
linktitle: "Comparing two objects: how hard can it be?"
title: "Comparing two objects: how hard can it be?"
highlight: true
---

**TL;DR**: Comparing the values of simple objects of unknown types in .NET can be a pain. Here is the story of how I achieved it ([and the code!](https://gist.github.com/rdumont/d0392668185337ae707a)).

This week I had to implement a thing that saves settings for, well, something. Each setting should be saved individually, so all I had as input was the **key (a `string`)** and the **value (`an object`)**. I had to treat the value as object because, coming from JSON, it could be anything, from a number (integer or not), `string`, date or boolean to an arbitrary map or array.

The issue was that, since the action of saving a value created a log for auditing, **I didn't want to actually save it if there were no changes**. That is, when the value sent is the same as the already persisted one. **Easy!**—I say—**there should be something in the framework that does this for me**. As it turns out, there isn't a safe and loose equality comparer for the object type.

Enough said! There is no better way of showing what I wanted than with a test suite—for which I used [NUnit](http://nunit.org/). First, these are the cases in which I want the values to be **considered equal** ([or see the Gist](https://gist.github.com/rdumont/d0392668185337ae707a#file-settingsvalueequalitycomparertests-cs-L8-L29)):

```csharp
private readonly object[][] successCases =  
{
    new object[] {"abc", "abc"},
    new object[] {123, 123},
    new object[] {1.0, 1},
    new object[] {123, 123L},
    new object[] {123L, 123},
    new object[] {new DateTime(2014, 1, 1), new DateTime(2014, 1, 1)},
    // It is important to know that values parsed from JSON are treated correctly
    new object[] {JToken.Parse("123"), JToken.Parse("123")},
    new object[] {null, null},
};

[TestCaseSource("successCases")]
public void Success(object a, object b)  
{
    // Arrange
    var comparer = new SettingsValueEqualityComparer();

    // Act & Assert
    Assert.That(comparer.Equals(a, b), Is.True);
}
```

And now the cases in which values should be **considered different** ([or see the Gist](https://gist.github.com/rdumont/d0392668185337ae707a#file-settingsvalueequalitycomparertests-cs-L31-L61)):

```csharp
private readonly object[][] failureCases =  
{
    new object[] {"abc", "def"},
    new object[] {"abc", 123},
    new object[] {123, "abc"},
    new object[] {123, "123"},
    new object[] {123, 456},
    new object[] {123L, 456},
    new object[] {123, 456L},
    new object[] {new DateTime(2014, 1, 1), new DateTime(2000, 12, 31)},
    new object[] {"abc", new DateTime(2000, 12, 31)},
    new object[] {new DateTime(2014, 1, 1), "abc"},
    new object[] {JToken.Parse("123"), JToken.Parse("456")},
    // arrays and objects should never be considered equal, even if they seem to be
    new object[] {JToken.Parse("[]"), JToken.Parse("[]")},
    new object[] {JToken.Parse("{}"), JToken.Parse("{}")},
    new object[] {JToken.Parse("{}"), JToken.Parse("[]")},
    new object[] {new {a = "b"}, new {a = "b"}},
    new object[] {"abc", null},
    new object[] {null, "abc"},
};

[TestCaseSource("failureCases")]
public void Failure(object a, object b)  
{
    // Arrange
    var comparer = new SettingsValueEqualityComparer();

    // Act & Assert
    Assert.That(comparer.Equals(a, b), Is.False);
}
```

Simple, right? Except not. The .NET Framework has **11 types of numeric values**, which cannot be directly compared to one another. Also, everything that tries to compare **different types throws an exception**, which isn't what I want. I just want `true` or `false`, no exceptions. That said, here is the implementation that saved the day ([or see the Gist](https://gist.github.com/rdumont/d0392668185337ae707a#file-settingsvalueequalitycomparer-cs)):

```csharp
public class SettingsValueEqualityComparer : IEqualityComparer<object>  
{
    public new bool Equals(object a, object b)
    {
        // If the equality operator considers them to be equal, great!
        // Both being null should fall in this case.
        if (a == b)
            return true;

        // Now we know that at least one of them isn't null.
        // If the other is null, then the two are different.
        if (a == null || b == null)
            return false;


        // Let's see if they are both numbers. In that case, they should
        // be compared as decimals, which fits any of the other number types.
        var na = IsNumeric(a);
        var nb = IsNumeric(b);
        if (na && nb)
            return Convert.ToDecimal(a) == Convert.ToDecimal(b);

        // We found that at least one of them isn't a number.
        // If the other is, then the two are different.
        if (na || nb)
            return false;

        // Our last resort is to check if one of them is IComparable.
        // If it is and the other has the same type, then they can be compared.
        var ca = a as IComparable;
        if (ca != null && a.GetType() == b.GetType())
            return ca.CompareTo(b) == 0;

        // Anything else should be considered different.
        return false;
    }

    private static bool IsNumeric(object value)
    {
        // Yes, 11 types. And they cannot be directly compared using the IComparable
        // interface because an exception is thrown when different numeric types are used.
        return value is sbyte
                || value is byte
                || value is short
                || value is ushort
                || value is int
                || value is uint
                || value is long
                || value is ulong
                || value is float
                || value is double
                || value is decimal;
    }

    public int GetHashCode(object obj)
    {
        // I don't need this method, so here is a simple implementation just because
        return obj == null ? 0 : obj.GetHashCode();
    }
}
```

So, on the way of implementing a small feature (saving settings), my teammate and I got stuck for roughly three long hours trying to figure out what then seemed to (and should!) be trivial: comparing two simple objects.

It was a process of trial and error, but I still can't quite believe that it takes all this code. **Do you know of a better way to do it?** If you do, please leave a comment or [contribute with the Gist](https://gist.github.com/rdumont/d0392668185337ae707a).
