# Theia code example

```python
#syntax for this language was designed to be easy-to-read and easy-to-understand
#some features are just sugar, but if you want to use them - no problems
#you can combine C-style with JavaScript-style of programming
#there is all possible types of data that you need, i.e. int, float, uint256, string, arrays, etc
#and keep in mind - this is just an example of early version of Theia

#this contract is an example of "Hello, World!"
contract Example {
  string hello = "Hello, World!";
}

#examples of functions

@Paid #attribute to define this function as payable (executing this function on VM takes gas)
function type1() bool {
  return true;
}

#also payable function
bool type2() paid {
  return true;
}

#payable function with dynamic returning type
#compiler will decide wich type you have returned
type3() paid {
  return true;
  #return 10;
  #return "example";
}

#anonymouse paid function
#if {...} block contains "return" keyword it is an anonymouse function
{paid(); return true;}


#some words about contracts
#contracts are similar to classes in Java or C++, but in Theia their is also a "class" keyword which is the same like in Java or C++

contract ParentExample {
public:
  string word = "hello";
#or
# public string word = "hello world";
#by default all variables are private
}

#you can inherit contracts
contract Example extends ParentExample {
  string phrase = word + " world!";
}

#their is also a "friend" keyword
#it allows you to manipulate contract variables in external function
contract Carrots {
  friend increaseCarrotsFriend; #tells contract that he has a friend function
  public int carrots = 1000; #this variable must be public
  
  #this function changed variable value so it must be paid
  public increaseCarrots() paid {
    carrots += 10; #increase "carrots" variable in "Carrots" contract 
  }
}

#this function does the same as function "increaseCarrots" in "Carrots" contract cause it was defined as friend for "Carrots" contract 
increaseCarrotsFriend() paid {
  carrots += 10; #increase "carrots" variable in "Carrots" contract 
}

contract CarrotsFarmer {
  increaseCarrotsFriend(); #call function wich will increase carrots
}

#more features in a future
```
