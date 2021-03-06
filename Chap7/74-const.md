# 7.4 const

さて、ここまで文字列リテラルに対する変更操作(書き込み操作)は未定義であると述べてきました。よって以下のようなコードは正しく動きません。
```cpp
int main()
{
	char* str="hoge";
	str[1]='a';
}
```
しかし、コンパイルは通ってしまう事があります。正しく動かない事が初めから分かりきっているのであれば、このようなコードはコンパイルエラーにしてしまって未然に防ぎたいものですよね。


## 7.4.1 constキーワード

これを防ぐためには、変数に対する変更操作を禁止する事で実現できそうです。C++には、そのためのキーワードが用意されています。
```cpp
int main()
{
	const char* str="hoge"; 
	char const* str1="hoge"; // 同じ意味
	str[1]='a'; // エラー！
	str1[1]='a'; // エラー！
}
```
`const`キーワードです。これを識別子名の前に付与する事でその変数に対する書き込み操作を禁止する事ができます。上記のように二つの記述法がありますが、どちらも同じ意味です。

この場合、ポインター変数に対して`const`を指定していますが、以下のような操作は許されます。
```cpp
#include<iostream>
int main()
{
	const char* str="hoge";
	str="foo";
	std::cout<<str<<std::endl;
}
```
実行結果は以下となります。
```cpp
foo
```
`const`を指定しているのにも関わらず変更できているじゃないか！と思うかもしれませんが、この場合禁止しているのは**ポインターが指している先の実態データに関する変更操作**であって、**ポインターが指し示す先の変更操作**ではないからです。
**ポインターが指し示す先**も固定したい場合、以下のように記述します。
```cpp
int main()
{
	const char* const str="hoge"; // ポインターが指し示している実態とポインターが指し示すものを固定
	char const* const str1="hoge"; // 同じ意味
	
	// 以下は全てエラー
	str="foo";
	str1="foo";
	str[0]='a';
	str1[0]='a';
}

```

この機能は、勿論ポインター型以外にも使う事ができます。
```cpp
int main()
{
	const int a=10;
	const char b='a';
	a=42; // エラー！
	b='b'; // エラー！
}
```
また、関数の引数に付与する事もできます。
```cpp
#include<iostream>
int func(const int l,const int r)
{
	l=10; // エラー！
	r=20; // エラー！
	return l+r;
}

int main()
{
	int x=10,y=20;
	std::cout<<func(x,y)<<std::endl;
}
```
このようにする事で、引数にされた変数に対する変更操作を禁止する事ができます。これは、ポインターを渡す時、また、まだ説明していませんがこれから取り扱う概念である参照と組み合わせる時に、より有用的な効果が発揮されます。ここでは、ポインターでの例を示します。
```cpp
void f(int* ptr)
{
	// *ptr=42 などといった変更操作が行われればxの値は変わってしまうかもしれない...
}

int main()
{
	int x=10;
	f(&x);
}
```
このように、アドレスを渡したいが関数`f`で`x`に対する変更操作は行わないでほしいとします。しかし、プログラマーが意識しないうちに何気なく変更操作をおこなってしまうコードを書いてしまうかもしれません。そういった場合に、`const`を利用します。
```cpp
void f(const int* ptr)
{
	*ptr=42; // 間違えて変更操作を行ってしまったがconstのためエラーになってくれる。
}

int main()
{
	int x=10;
	f(&x);
}
```
また、例えば以下のように別の関数内でポインターの指し示す先を変えてしまうコードがかけてしまう事で、意図しない動きになってしまうかもしれません。
```cpp
#include<iostream>

void f(int* ptr)
{
	int a;
	ptr=&a; // ptrはxとは違うアドレスを指している
	*ptr=20; // xと同じアドレスに対する操作のつもり
}

int main()
{
	int x=10;
	f(&x);
	std::cout<<x<<std::endl; // 20になってほしい
}
```
こういった場合にも、`const`を用いてポインターの指し示す先を固定する事で未然にエラーにする事ができます。
```cpp
#include<iostream>
void f(int* const ptr)
{
	int a;
	ptr=&a; // エラーとなる
	*ptr=20; 
}

int main()
{
	int x=10;
	f(&x);
	std::cout<<x<<std::end
}
```
因みに、`const`指定された変数は初期化時になんらかの値を与えなければなりません。
```cpp
const int a; // エラー！初期化値が指定されていない
```
`const`はその性質上、代入操作は許されていませんから、初期化時点で値を与えないと何の意味もなくなってしまいますので、この挙動も当然ですね。

## 7.4.2 const_cast
「2.1.9 キャスト」でキャストについて述べた際、`const_cast`について述べていませんでした。`const_cast`は、`const`指定されたオブジェクトの`const`性を排除するキャストです。
```cpp
#include<iostream>

int main()
{
	const int x=0;
	const int* const a=&x; // ポイントする先も変更しないし、ポイント先の値も変更しない
	
	std::cout<<*a<<std::endl;
	int* const b=const_cast<int* const>(a); // ポイントする先は変更しないが、ポイントする先の値は変更する

	*b=30;
	std::cout<<*a<<std::endl;
}
```
実行結果は以下となります。
```cpp
0
30
```
ポインター、`a`はポイント先も、ポイント先の値も`const`と指定していますが`const_cast`によって変更できてしまいました。

このように、`const_cast`は、`const`なオブジェクトという、変更がされないという決まりごとを強引に排除してしまうキャストです。よって、特別必要がない限り、`const_cast`によって`const`を排除するべきではありません。上記の場合であれば`const_cast`を使うのではなく、初めから`const`なオブジェクトとして定義しなければ良いのです。