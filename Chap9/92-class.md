# 9.2 非POD型を含む構造体、クラスの機能と概念

9.1では、POD型という構造体、クラスの根本的、基本的な概念を学びましたがこれらはC言語でも扱うことのできる機能です。

ここからは、POD型の制限を破り、C++言語のさらなる高性能な言語機能を扱っていきます。これらの言語機能を使いこなせるようになれば、明快で多彩なコーディングを意識づける事ができるようになります。一つずつ順にマスターしていきましょう。

以降、構造体/クラスについては一貫してクラスと呼称しています。

## 9.2.1 アクセス指定子によるアクセス領域の制御
「9.1.2独自の型」では構造体/クラスの例として以下のように示しました。
```cpp
struct Vector{
	int x,y,z;
};
```
もしくは
```cpp
class Vector{
public:
	int x,y,z;
};
```
この時、`class`キーワードを用いる場合、`public`というキーワードを用いていました。これは、アクセス領域を指定しているのです。アクセス領域には以下の種類があります。

* pubilc
* protected
* private

これらは全て**アクセス指定子**と言われます。この中で、`protected`は、さらに後に取り上げる概念である継承を理解した後に活かされるアクセス指定子のためここでは一旦取り上げずに、`private`と`public`のみを説明します。

まず**`public`指定されたアクセス領域にある全てのメンバは、クラス外からも直接アクセスできます**。逆に**`private`指定されたアクセス領域にある全てのメンバはクラス内の関数からしかアクセスする事はできません**。そして、**`struct`キーワードで定義されたクラスのデフォルトアクセスレベルは、`public`、`class`キーワードで定義されたクラスのデフォルトアクセスレベルは`private`です**。
```cpp
struct X{
 // public ...
};
```
```cpp
class X{
 // private ...
};
```
実際にコードを書く事でより理解が深まるでしょう。
```cpp
struct X{
    int a;
};

class Y{
    int a;
};

int main()
{
    X x={10};
    Y y={10};
}
```
このコードはコンパイルが通りません。GCC 7.0.1でのエラー文は以下のように出力されます(一部を特出しています)。
```cpp
12:4: error: no matching constructor for initialization of 'Y'
        Y y={10};
          ^ ~~~~
````
特に`X`についてのエラーが出力されていない通り、`X`については正しいコードです。`X`についてはクラス内部でアクセス指定を全くしていませんが、デフォルトでアクセスレベルは`public`であるため、外部からアクセス可能です。よって正しく処理されます。
エラー文は、Yをインスタンス化する段階で発生しています。`Y`についても、内部でアクセス指定子を用いていませんが、`class`キーワードを用いてクラスを定義した場合、デフォルトのアクセスレベルは`private`となります。エラー文を見てみるとエラーの内容は、「no matching constructor」と出力されています。どうやら、constructorなるものがマッチしないようです。
constructorとは一体なんでしょうか。

## 9.2.3 コンストラクター
constructor(コンストラクター)とは、**クラスがインスタンス化される段階で一番最初に呼ばれる関数**です。コンストラクターはクラスをインスタンス化する際に初期化を行う特殊な関数なのです。

まずコンストラクターの雰囲気を掴むためにもコンストラクターの簡単な特徴を示します。

* クラス名と同じ名前の関数
* 戻り型がvoidではないが戻り値がない

これらを踏まえて実際にコンストラクタを使った最も簡単な例を以下に示します。
```cpp
struct X{
	X(){} // コンストラクター
};
```
```cpp
class X{
public:
	X(){} // コンストラクター
};
```
`struct`、`class`両キーワードを用いた場合を記載しました。上記のように、コンストラクタは`public`アクセスレベルの中で宣言/定義されていなければ外部からそのクラス自体をインスタンス化する事ができないため上記のように設定しています。
コンストラクタは、前述したようにインスタンス化される段階で必ず呼び出される関数です。実際に確認してみましょう。
```cpp
#include<iostream>
struct X{
    X(){std::cout<<"X constructor"<<std::endl;}
};

class Y{
public:
    Y(){std::cout<<"Y constructor"<<std::endl;}
};

int main()
{
    X x;
    Y y;
}
```
実行結果は以下となります。
```cpp
X constructor
Y constructor
```
このように、`X`、`Y`からオブジェクトを生成しただけでコンストラクタの内容が実行されている事が分かります。
ここで、先ほどエラーになったコードをもう一度見て見ましょう。
```cpp
struct X{
     int a;
};

class Y{
     int a;
};
int main()
{
     X x={10};
     Y y={10};
}
```
前述した通り、コンストラクタは`public`アクセスレベル中で宣言/定義されなければ外部からそのクラスをインスタンス化する事ができません。`Y`がこの時インスタンス化できないのは、`class`キーワードによって全てのアクセスレベルが`private`になっているからです。では、`Y`にコンストラクタを追記しましょう。
```cpp
class Y{
	int a; // aのアクセスレベルはprivate
public:
	Y(){} // コンストラクタのアクセスレベルはpublic
};

int main()
{
	Y y={10];
}
```
しかし、残念ながらまだこのコードはコンパイルエラーとなります。エラー文を見て見ましょう。
```cpp
11:4: error: no matching constructor for initialization of 'Y'
        Y y={10};
          ^ ~~~~
```
おっと...エラー文は全く変わりません。`Y`のinitialization、つまり`Y`の初期化においてマッチするコンストラクターがないという内容です。何故でしょうか？コンストラクターのアクセスレベルを`public`にして外部からもオブジェクトを生成できるようにしたはずです。

結論から言えば、コンストラクターは、実は引数を受け付ける事ができるのです。そして、コンストラクタの引数は、オブジェクト生成時の初期化値として与える事ができるのです。具体的には、以下のようにコンストラクタを記述します。
```cpp
#include<iostream>

class Y{
    int a;
public:
    Y(int param)
    {
        a=param;
	std::cout<<a<<std::endl;
        std::cout<<"Y constructor"<<std::endl;
    }
};

int main()
{
    Y y={10};
}
```
実行結果は以下の通りです。
```cpp
10
Y constructor
```
`Y`のコンストラクターを見て見ましょう。引数に`int`型を受け取るようになっています。つまりコンパイラの求めていたmatchingするコンストラクタとは、このようなコンストラクタであった事が分かります。
コンストラクタの内部を見て見ましょう。内部では自身のメンバ変数`a`に、引数で受け付けた`param`を代入しています。その後"Y constructor"という文字列を出力しています。
ここで一つ引っ掛かる点があります。コンストラクタは、生成されたオブジェクトに対する初期化操作のはずです。しかし、メンバ変数`a`に対する値の適用は、上記の記述だと、代入という操作が行われているのです。初期化と代入は全く異なるものであるという事を思い出してください。コンストラクタは初期化を行う機構である以上、初期化操作でなければなりません。
しかし、安心してください。コンストラクタで、メンバ変数を初期化する構文は、言語仕様によって準備されています。
```cpp
#include<iostream>

class Y{
    int a;
public:
    Y(int param):a(param)
    {
        std::cout<<a<<std::endl;
        std::cout<<"Y constructor"<<std::endl;
    }
};

int main()
{
    Y y={10};
}
```
実行結果は以下の通りです。
```cpp
10
Y constructor
```
`Y`のコンストラクタを見てください。引数の後に`:a(param)`というように続いています。このようにコンストラクタの引数の後に、`初期化したいメンバ:(初期化する値)`というように記述する事で、そのメンバを代入での値の適用ではなく、初期化として値を適用する事ができるのです。
上記の代入と初期化では、確かに結果的には全く同じです。しかし、前述した通り、初期化と代入の違いを明確化し、適切に処理する事は多くのシーンで有益な働きを齎します。初期化可能なメンバ変数は、積極的に初期化の構文で値を適用するべきなのです。

ところで、上記のように引数付きのコンストラクタを定義した場合、引数なしでインスタンス化する事はできるのでしょうか。引数なしのコンストラクタは定義されていないため、引数なしのインスタンス化はできないように思えます。
```cpp
// クラスYについての定義。
// 上記と同様

int main()
{
    Y y; // 引数なしでYをインスタンス化
}
```
予想の通り、引数なしで`Y`をインスタンス化すると、コンパイルエラーが発生します。コンパイルエラーの文面は先ほどから良く見る、「no matching constructor for initialization」のはずです。
こういった場合、引数なしのコンストラクタも用意してあげる事で、可能です。
```cpp
#include<iostream>

class Y{
    int a;
public:
    Y():a(0)
    {
        std::cout<<a<<std::endl;
        std::cout<<"Y constructor(param 0)"<<std::endl;
    }
    Y(int param):a(param)
    {
        std::cout<<a<<std::endl;
        std::cout<<"Y constructor(param 1)"<<std::endl;
    }
};

int main()
{
    Y y1;
    Y y2={10};
}
```
実行結果は以下となります。
```cpp
0
Y constructor(param 0)
10
Y constructor(param 1)
```
`y1`のインスタンス化では引数なしのコンストラクタを、`y2`のインスタンス化では`int`型を一つ受け取るコンストラクタを呼び出しています。どのようにして呼び分けているのでしょうか...ここまででこれと似たような動作をするものを、既に習得したはずです。
そうです、これは、関数のオーバーロードによって達成されているのです。コンストラクタも関数ですから、上記のようにオーバーロードすることが可能です。
もちろん、デフォルト引数を設定しておく事も可能です。
```cpp
struct Y{
	Y(int a,int b=10):a(a),b(b){}
private:
	int a,b;
};

int main()
{
	Y y={20}; // デフォルト引数が設定されているため引数が1つでも良い。この場合bは10で初期化される。
}
```
細かい点ですが、引数なしの`Y`のコンストラクタで、メンバ変数`a`を`0`で初期化しています。`0`という値でなければならないという事ではないのですが、初期化されていない、不定値として放っておく事はあまり好ましい事ではありません。しかし、引数なしのコンストラクタの場合、初期化する値も特にないので、こういった場合は`0`という値でメンバ変数を初期化しておくのが、念のためにも安全なコードと言えます。

さてさて、コンストラクタは、もう少し奥が深いのでさらに突っ込んで話していきましょう。
先ほどまでのコードでは、インスタンス化において以下のように記述してきました。
```cpp
Y y={10};
```
初期化するにはこのように記述しなければならないのかと思ってしまった方、ご安心ください。以下のように、いくつか初期化の記述の方法が用意されています。
```cpp
Y y1=10;
Y y2{10};
Y y3(10);
Y y4={10}; 
```
これらは、クラス`Y`の定義が上記である場合、全て同じように動作します。
逆に、何故こんなにも色々な記述方法が用意されているのだ?!紛らわしいと思うかもしれません。確かにその通りこれはとても紛らわしいのですが、一つ一つ意味合いが明確なのです。

初めの`=`を用いた初期化。これは、プリミティブ型の初期化と同じように記述できるために用意された記述法です。ユーザーが独自に定義した型と、プリミティブ型が同じように初期化式を書く事ができるというのは、統一性から見ると大きなメリットです。
```cpp
int i=10; // プリミティブ型intの変数iを10で初期化
Y y=10; // ユーザーが独自に定義したクラスYを10で初期化
```
次に`{}`を用いた初期化方法。これは、**Uniform initialization**と呼ばれる記述方法で、翻訳すれば統一記法といったところでしょうか。統一的な記法、何に対しての統一なのかと思われるかもしれませんが、例えばPOD型に対する初期化と`private`なメンバを持つようなここまで説明してきた非POD型に対する初期化の記述方法などが挙げられます。Uniform initializationがなかった場合、POD型に対する初期化は以下のように記述する事となります。
```cpp
struct POD{ int x; };
POD pod={10};
```
そいて非POD型に対する初期化は以下のように記述する事となります。
```cpp
// 非POD型Yの定義を省略。上記と同様
Y y1=10;
Y y2(10);
```
これらは全て統一されていません。Uniform initializationは全ての初期化文を統一的に記述する事ができる事を売りにした初期化の記述法なのです。

次に`()`を用いた初期化方法。これは、複数個の引数を受け付けるコンストラクタを設定した場合や、明確な初期化の意思表示で不可欠となる記法です。`Y`のコンストラクタを二つの引数で受け付けるようにしてみましょう。
```cpp
class Y{
	int a,b;
pubilc:
	Y(int a_,int b_):a(a_),b(b_){}
};
```
初期化は、以下のように行います。
```cpp
Y y(10,20);
```
尚、Uniform initializationもこの場合有効です。
```cpp
Y y{10,20};
```
Uniform initializationは比較的新しい記法なので、このような`()`を用いなければならない状況においても、統一的に記述する事ができるのです。

最後に、`={}`を用いた記法。これは、C言語由来からなる構造体の初期化の記法です。C++言語はC言語との互換性を可能な限り維持する傾向にあるという認識もあり、そのような意思表示がこのような部分から垣間見る事ができます。

尚、先ほどコンストラクタの引数に対してデフォルト値を与えることができると述べましたが、以下のようにしてもデフォルトの初期化値を定めることができます。
```cpp
struct X{
   int a=10; // 変数の宣言に対して直接初期化文を記述する
};

int main()
{
    std::cout<<X().a<<std::endl;
}
```
実行結果は以下となります。
```cpp
10
```
上記のように変数に対して直接初期化文を記述し、更にコンストラクタに対してデフォルト値を設定した場合、コンストラクタに設定された値が優先されます。
```cpp
struct X{
    X(int x=42):a(x){}
    int a=10;
};

int main()
{
    std::cout<<X().a<<std::endl;
}
```
実行結果は以下の通りです。
```cpp
42
```

## 9.2.4 explicit、constexpr、inline、noexcept コンストラクター
前述した様々な初期化の記法の中で`=`を用いた初期化の方法について取り上げます。
まず、`=`を用いたオブジェクトの初期化は、コンストラクタの引数が必ず1つでなければなりません。よくよく考えてみれば、当然の事です。`=`に対して直接引数を二つ以上与える記法は、あまりにも直感に反します。
ところで、この`=`、前々から思っていたかもしれませんが、初期化と代入は全く違う動作であるという事をこの文書では何度も述べていますが、意味合いが事なるのに全く同じように記述しなければならない事は、場合によっては紛らわしく、また独自的に作成したクラスを用いているのか、プリミティブ型を用いているのかを明確化したい場合には、`=`の記法で初期化させたくない場合があります。
そのような要望に答えるのが`explicit`コンストラクターです。
```cpp
class Y{
	int a,b;
public:
	explicit Y(int a_):a(a_){}
};
```
このように設定した場合、`Y`のインスタンス化時、初期化構文として`=`を用いる事が許されなくなります。
```cpp
Y y1(10); // OK
Y y2{10}; // OK
Y y3=10; // NG
Y y4={10}; // NG
```
`()`を用いた初期化式が許可されると同時に、Uniform initializationは依然として許可されます。これは、前述したようにUniform initializationが統一的な記法を援助するためのものだからです。
多くの場合、プリミティブ型の初期化には`=`が使われますが、実はプリミティブ型も`()`や`{}`で初期化を行う事が可能です。
```cpp
int i(10); // 10で初期化
int j{20}; // 20で初期化
```
プリミティブ型の初期化に`()`か`{}`を用いて引数を設けなかった場合、その変数は0で初期化されます。

またコンストラクターは`constexpr`指定する事ができます。よって、コンストラクタは積極的に`constexpr`にするべきです。(本文書ではそれぞれの項目ごとに置ける重要なポイントを明確にするため、`constexpr`なコンストラクタにしていないシーンがあります。)
```cpp
struct Y{
    constexpr Y(int a):a(a){}
private:
    int a;
};

int main()
{
    Y y=10;
}
```
勿論、`explicit`との併用が可能です。
```cpp
struct Y{
    explicit constexpr Y(int a):a(a){}
private:
    int a;
};

int main()
{
    Y y(10); // =を用いた初期化は行えない。
}
```

コンストラクタは`inline`指定も可能です。
```cpp
struct Y{
	inline Y(){}
};
```
挙動は、関数のインラインかと全く変わりません。

また、関数の場合と同じく、例外が発生しない事を保証するnoexcept属性を付与することもできます。
```cpp
struct Y{
	Y()noexcept{}
};
```

## 9.2.5 デフォルトコンストラクター
ここまで基本的なコンストラクターの概要を見てきましたが、ところでコンストラクターを定義していないクラスは何故インスタンス化できるのだろうか？と疑問には思いませんでしょうか。
具体的に示せば以下のようなコードです。
```cpp
struct X{}; // コンストラクタ等、何も記述していない

int main()
{
	X x; // インスタンス化できる
}
```
これは何故正しくインスタンス化できるのでしょうか。
結論から言えば、これは、**コンパイラによって暗黙的にコンストラクターが定義されているから**です。
その暗黙定義されたコンストラクターを、また暗黙定義されたかに関わらず実引数を与えずに呼び出すことが可能なコンストラクタを**デフォルトコンストラクター(default constructor/default ctor)**と言います。
デフォルトコンストラクタが暗黙的に定義される条件は以下の通りです。

* 任意のコンストラクターを一つも定義していなく、デストラクタ、コピー代入演算子、ムーブ代入演算子が宣言される場合
* 任意のコンストラクターを一つも定義していなく、コピーコンストラクタ、ムーブコンストラクタを宣言していない場合


上記の`X`は、暗黙的にデフォルトコンストラクターが定義されたという事になります。つまり、下記
の内容と同じ動作を行うという事です。
```cpp
struct X{
	X(){}
};
```
しかし、例えば引数を受け付けるコンストラクタを用意した場合に、それとは別に引数がなければ、暗黙的に定義されるコンストラクタと同じように動くようにしたいといった場合、コンストラクタを上記のように一々記述しなければならないのは、なんとも面倒ですし、明示性に欠けるものがあります。
そのような場合には、`default`を用いる事でデフォルトコンストラクターを明示的に定義する事が可能です。
```cpp
struct X{
	X()=default; // デフォルトコンストラクタ
	X(int x):x_(x){} // 引数付きのコンストラクタ
private:
	int x_;
};
```
この`default`によるデフォルトコンストラクタの機能はとても便利で、例えばデフォルト挙動をして欲しいがそのコンストラクタは`constexpr`にしたいといった場合、以下のように記述できます。
```cpp
struct X{
	constexpr X()=default; // constexpr版デフォルトコンストラクタ
};
```
`explicit`、`inline`なども同じように指定できます。

## 9.2.6 引数を工夫する
ここまでで説明に扱ってきた、例えばクラス`X`では、以下のようなコンストラクタを用意していました。
```cpp
struct X{
	X()=default;
	X(int x):x_(x){}
private:
	int x_;
};
```
`X`のコンストラクタの内、引数を受け付けるものは`int`型の値を受け取りますが、これは関数の場合と同じく値をコピーします。この場合、`int`型なのでコピー動作が起きたところで大したオーバーヘッドにはなりませんが、例えば巨大なオブジェクトだったりした場合では、関数の値渡しの場合と同じように、それなりのオーバーヘッドを抱える事となります(それが意図された動作だとすれば問題はありません)。
無意味なコピーはとてもよろしくないので、通常の関数と同じように、参照やムーブなどで無駄なオーバーヘッドを削減しましょう。
```cpp
struct X{
	X(const int& x):x_(x){} // 引数を参照で受け取る
private:
	int x_;
};
```
```cpp
struct X{
	X(int x):x_(std::move(x)){} // 引数はコピーで受け取るが初期化時にムーブ
private:
	int x_;
};
```

## 9.2.7 コピーコンストラクタ
プリミティブ型と同じように、独自に定義したクラスをコピーしたくなる場合も勿論あるはずです。
```cpp
int i=42;
int j=i; // コピー
```
ここで、コピーはコピー代入(assign)とは異なることを再認識しなければなりません。
```cpp
int i=0;
int j=i; // コピー
i=42; // コピー代入(assign)
```
まずはコピーを独自に定義したクラスでも実現してみましょう。
といっても、とても簡単です。単に、自らの型を受け付けるコンストラクタを定義すれば良いのです。
```cpp
#include<iostream>

struct X{
    X(int x):a(std::move(x)){}
    X(const X& other):a(other.a){} // コピーコンストラクタ
    int a;
};

int main()
{
    X x1=42;
    X x2=x1;
    std::cout<<x2.a<<std::endl;
}
```
実行結果は以下の通りです。
```cpp
42
```
`const X&`で受け取り、内部のメンバをコピーする事で、オブジェクトがコピーされます。
ところで、以下のようなコードもまた正しく動作します。
```cpp
struct X{};

int main()
{
    X x1;
    X x2=x1; // コピー
}
```
`x1`のインスタンス化については前述したようにデフォルトコンストラクタによる動作である事が伺えます。しかし、コピー操作について、定義していないのにも関わらずこのコードはコンパイルに成功します。
というのも、これは、**デフォルトのコピーコンストラクタが生成されているから**です。
デフォルトのコピーコンストラクタが生成される条件は、以下の通りです。

* ムーブコンストラクタもしくは代入演算子をユーザ宣言しておらず、デフォルトコンストラクタ、任意のコンストラクタ、デストラクタ、コピー代入演算子が宣言される場合。但し、デストラクタとコピー代入演算子の宣言によって暗黙定義されるコピーコンストラクタの使用は非推奨である。

よって、実は先ほどのコードも、デフォルト動作で良いのであればわざわざ定義する必要はないのです。
```cpp
#include<iostream>

struct X{
    X(int x):a(std::move(x)){}
    // コピーコンストラクタを宣言/定義しなくとも、コンストラクタが定義されているためコピーコンストラクタは暗黙定義される
    int a;
};

int main()
{
    X x1=42;
    X x2=x1;
    std::cout<<x2.a<<std::endl;
}
```
非推奨な暗黙定義は以下のような場合です。
```cpp
#include<iostream>

struct [[deprecated]] generate_from_dtor{
    ~generate_from_dtor()
    {
        std::cout<<__func__<<std::endl;
    }
};

struct [[deprecated]] generate_from_copy_assign{
    generate_from_copy_assign& operator=(const generate_from_copy_assign&)
    {
	return *this;
    }
};

int main()
{
    generate_from_dtor a;
    [[maybe_unused]] generate_from_dtor b=a; // ユーザー定義デストラクタによって暗黙定義されたコピーコンストラクタを使用。しかし非推奨。

    generate_from_copy_assign c;
    [[maybe_unused]] generate_from_copy_assign d=c; // ユーザー定義コピー代入演算子によって暗黙定義されたコピーコンストラクタを使用。しかし非推奨。
}
```
`[[deprecated]]`は、宣言された対象が非推奨であることを明示するatrributeです。attributeについては別途詳しく取り上げますので、現時点では気にしなくて大丈夫です。
また、コピーコンストラクタもコンストラクタと同じようにデフォルトでの暗黙宣言を明示できます。
```cpp
struct X{
    X(const X&)=default; // デフォルトコピーコンストラクタを明示的に生成
};
```
さらに、コンストラクタと同様、`constexpr`や`inline`指定が行えます。よって、可能な限り積極的に`constexpr`指定するべきです。
```cpp
struct X{
    constexpr X(const X&)=default; // デフォルトコピーコンストラクタの動作をconstexpr指定
};
```
通常のコンストラクタと同じように、コピーコンストラクタも`noexcept`指定が可能です。
```cpp
struct X{
    X(const X&)noexcept=default;
};
```

## 9.2.8 コピー代入
コピーコンストラクトができたら、次はコピー代入がしたいところですね。
コピー代入演算子の定義は、主に演算子のオーバーロードとthisポインタを用います。この項では、まだ両者について深く触れませんが、コピー代入の定義の雰囲気を掴むためにも、ここでコピー代入演算子の概要に一度触れておく事とします。
コピー代入演算子は以下のように記述します。
```cpp
#include<iostream>

struct X{
    X()=default;
    X(int x):a(std::move(x)){}
    X& operator=(const X& other) // コピー代入演算子
    {
        a=other.a;
        return *this;
    }
    int a;
};

int main()
{
    X x1=42,x2;
    x2=x1;
    std::cout<< x2.a <<std::endl;
}
```
実行結果は以下の通りです。
```cpp
42
```
何やら`operator=`だの、`this`だのといった謎の記述が気になるところですので、ここでは大まかに概要だけ説明します。但し現時点では完全に理解する必要はありません。
まず、代入を行うためには、演算子のオーバーロードという文法を用いて、`=`演算子をオーバーロードします。それを示すのが、`operator=`です。`operator`というキーワードの後に、対象の演算子を記述する事で対象の演算子をオーバーロードする旨を意味します。この場合、クラス内で演算子をオーバーロードしているため、このクラス型から生成されたオブジェクトから成る`=`演算子の適用によって呼び出される事となります。
よって、`=`演算子の左辺側は必ず`X`型のオブジェクト、つまり自分自身という事になりますから、`=`演算子の右辺は一つのみなので、引数も必ず一つになります。今回は、コピー代入という動作を行いたいので、引数には自分自身の型を受け付けるように設定します(`const X&`)。
内部では、引数で受け取ったオブジェクトの値を自分自身の持つ変数に代入しています。
その後、何やら`*this`というものを返しています。
大まかに説明すると、一言で言うならば`this`は、自分自身へのオブジェクトのポインタです。それにたいして`*`を使い関節アクセスしていますから、`*this`とは自分自身そのものであるという事がわかります。
では、そもそも何故代入演算子の戻り値で自分自身を返す必要があるのでしょうか。
それは、以下のように連続的に記述でいるようにするためです。
```cpp
#include<iostream>

struct X{
    X()=default;
    X(int x):a(std::move(x)){}
    X& operator=(const X& other)
    {
        a=other.a;
        return *this;
    }
    int a;
};

int main()
{
    X x1=42,x2,x3;
    x3=x2=x1; // 連続的に代入
    std::cout<< x2.a <<std::endl;
    std::cout<< x3.a <<std::endl;
}
```
実行結果は以下の通りです。
```cpp
42
42
```
このように連続的に代入しようとした場合、戻り値に自分自身を返却するようにしなければ代入することはできません。戻り値がなかった場合、`x2=x1`の時点でまず`X`に定義されている`operator=`が呼び出されますが、その後の`x3`の`operator=`の呼び出しでは、引数に渡すものがなくなってしまうので、エラーとなってしまいます。

さて、代入演算子も、コンストラクタ、コピーコンストラクタと同じように、デフォルトで定義されます。上記のような単純な代入であれば、条件を満たすことでわざわざユーザー側で代入演算子を定義する必要もなくなります。条件は以下の通りです。

* ムーブコンストラクタもしくは代入演算子をユーザ宣言しておらず、デフォルトコンストラクタ、任意のコンストラクタ、デストラクタ、コピーコンストラクタが宣言される場合。但し、ユーザー宣言によるデストラクタ、コピーコンストラクタによって暗黙宣言されるコピー代入演算子を使用することは非推奨である。 

```cpp
#include<iostream>

struct X{
    X()=default;
    X(int x):a(std::move(x)){}

    int a;
};

int main()
{
    X x1=42,x2,x3;
    x3=x2=x1; 
    // コピー代入演算子は定義されていないが、
    // デフォルトコンストラクタ、任意のコンストラクタ(条件としてはその他暗黙的に定義されるデストラクタ、コピーコンストラクタが含まれる)が定義されているため
    // 代入演算子が暗黙定義される。
    
    std::cout<<x2.a<<std::endl;
    std::cout<<x3.a<<std::endl;
}
```
実行結果は以下の通りです。
```cpp
42
42
```
また、非推奨な例を以下に示します。
```cpp
#include<iostream>

struct [[deprecated]] generate_from_dtor{
    ~generate_from_dtor()
    {
        std::cout<<__func__<<std::endl;
    }
};

struct [[deprecated]] generate_from_copy_assign{
    generate_from_copy_assign()=default;
    generate_from_copy_assign(const generate_from_copy_assign&)
    {
        std::cout<<__func__<<std::endl;
    }
};

int main()
{
    generate_from_dtor a,b;
    a=b;

    generate_from_copy_assign c,d;
    c=d;
}
```
これまで見てきてお気づきかもしれませんが、コピー代入演算子も、`default`指定が可能であり`inline`、`noexcept`などの指定が通常の関数同様可能ですが、`constexpr`には、その特性上指定することはできません。
```cpp
#include<iostream>

struct X{
    constexpr X(int x=0):a(std::move(x)){}
    X& operator=(const X&)noexcept=default; // デフォルト代入演算子をnoexcept指定
    int a;
};

int main()
{
    X x1=42,x2,x3;
    x3=x2=x1;
    std::cout<<x2.a<<std::endl;
    std::cout<<x3.a<<std::endl;
}
```

## 9.2.9 ムーブコンストラクタ
全てのコピー操作ができるようになりました。次は独自に定義したクラス自身をムーブできるようにしてみましょう。
まず考えるべきなのは、ムーブをしてしまって良いような型というのは、一体どうんな型なのかという点です。
最もダメな例は、lvalue referenceをムーブしてしまう事でしょう。lvalue referenceがムーブされてしまうとダメである理由を理解するために、まずはコンストラクタの概念と切り離して通常の関数で話を進めます。以下のコードを見てください。
```cpp
void f(int& a)
{
    [[maybe_unused]] int b=std::move(a);
}

int main()
{
    int a=10;
    f(a);
    // aの値はもう使えない
}
```
`f`の引数型は`int&`、つまりlvalue referenceを受け取るようになっています。このコードの問題点はユーザー側、つまり`main`関数から呼び出した側からすれば、`f`に差し込んだ引数がムーブされている、つまりもう`a`の値を`main`関数内で使う事ができないという事を認識できない点です。こちらとしてはムーブしたくないオブジェクトをいつのまにか勝手に内部でムーブされて、気付いた時には使えなくなっていたとなっていたらとても困ります。
よって、ムーブするかどうかというのは、通常ユーザー側に指定させるべきなのです。
逆にムーブしてしまっても良い型というのはどのような型でしょうか。それは、rvalueである場合です。オブジェクトがrvalueになる場合というのは、無名のオブジェクトとしてインスタンス化するか、`std::move`によってrvalue referenceにキャストするかです。そのようなオブジェクトはムーブしてしまっても影響はありません。
よって、その関数内でムーブされる事を明示的にするためにも、rvalue referenceを受け取るように関数の引数型を設定します。
```cpp
void f(int&& a)
{
    [[maybe_unused]] int b=std::move(a);
}

int main()
{
    int a=10;
    
    // f(a); とは呼び出せない。
    f(std::move(a));
}
```

さて、ではムーブコンストラクタに話を戻しましょう。といっても、意識すべき事は全く同じです。自分自身の型でrvalue referenceとして受け取るように設定すれば良いことになります。
```cpp
#include<iostream>

struct X{
    X(int x=0):a(std::move(x)){}
    X(X&& other) // ムーブコンストラクタ
    {
        a=std::move(other.a);
    }
    int a;
};

int main()
{
    X x1(42);
    [[maybe_unused]] X x2=std::move(x1);
}    
```
引数型にrvalue referenceを設定することで、ムーブコンストラクタは必ず無名のオブジェクトか`std::move`経由で呼び出されます。
そして内部では単にメンバをムーブして完了です。当然ですが、ムーブ後のオブジェクト(`x1`)がどのようになっているかは分かりませんから、プリミティブ型の時と同じように再度値を適用しない状態で操作するなどといった事をしてはなりません。

さて、ムーブコンストラクタも、条件によって暗黙的に定義されます。条件は、以下の通りです。

* デストラクタ、コピーコンストラクタ、コピー代入演算子、ムーブ代入演算子が宣言されておらず、デフォルトコンストラクタ、任意のコンストラクタが宣言される場合

```cpp
struct X{}; // デフォルトコンストラクタの暗黙定義に伴い、デフォルトムーブコンストラクタも暗黙定義

struct Y{
    Y(int x):a(std::move(x)){} // 任意のコンストラクタ宣言があっても暗黙的にデフォルトムーブコンストラクタが定義される
    int a;
};

int main()
{
    X x1;
    [[maybe_unused]] X x2=std::move(x1);

    Y y1(42);
    [[maybe_unused]] Y y2=std::move(y1);
}    
```
`default`、`constexpr`、`inline`、`noexcept`などの指定も同じく可能です。尚、暗黙宣言されるムーブコンストラクタは`noexcept`指定がされているため、暗黙宣言されるムーブコンストラクタとの互換性を保ちたいのであれば、`noexcept`を指定し、そのように動作する必要があります。
```cpp
struct X{
    constexpr X(X&&)=default; // constexprなムーブコンストラクタとして宣言。default指定した場合自動的にnoexceptされる
};
```

## 9.2.10 ムーブ代入演算子
ムーブコンストラクトができたら、次はムーブ代入ができるようにしましょう。
ムーブ代入はコピー代入と同じく、主に演算子オーバーロードと`this`ポインタを用いる事で可能です。
```cpp
#include<iostream>

struct X{
    X(int x=0):a(std::move(x)){}
    X& operator=(X&& other)
    {
        a=std::move(other.a);        
        return *this;
    }
    int a;
};

int main()
{
    X x1=42,x2;
    x2=std::move(x1);
    std::cout<<x2.a<<std::endl;
}
```
実行結果は以下の通りです。
```cpp
42
```
ムーブ代入演算子も条件によって暗黙宣言されます。条件は以下の通りです。

* デストラクタ、コピーコンストラクタ、コピー代入演算子、ムーブコンストラクタが宣言されておらず、デフォルトコンストラクタ、任意のコンストラクタが宣言される場合
```cpp
#include<iostream>

struct X{}; // デフォルトコンストラクタが宣言されると同時に暗黙的にムーブ代入演算子が定義される

struct Y{
    Y(int x=0):a(std::move(x)){} // 任意のコンストラクタが定義されているため暗黙的にムーブ代入演算子が定義される
private:
    int a;
};

int main()
{
    X x1,x2;
    x1=std::move(x2);

    Y y1(42),y2;
    y2=std::move(y1);
}
```
これまでと同様、`default`、`inline`、`noexcept`など指定が可能ですが、コピー代入演算子の場合と同じく、`constexpr`はその特性上指定することはできません。
```cpp
#include<iostream>

struct X{
    X(int x=0):a(std::move(x)){}
    inline X& operator=(X&& other)=default; // デフォルトムーブ代入演算子をinlineに
    int a;
};

int main()
{
    X x1,x2;
    x1=std::move(x2);
}
```

## 9.2.11 デストラクタ
ここまで、各コンストラクタや代入演算子を定義してきましたが、オブジェクトが生成される時に呼び出されるコンストラクタに対して、オブジェクトが破棄されるタイミングで呼び出されるデストラクタというものについて、最後に説明します。
デストラクタは、以下のように記述します。
```cpp
struct X{
	~X(){} // デストラクタ
};
```
デストラクタは、`~`と、クラス名と同名な名前を持つ戻り値がなく(`void`ではない)引数がない関数として宣言することで使用できます。
デストラクタの動作が分かりやすいように以下のようなコードを実行してみると良いでしょう。
```cpp
#include<iostream>

struct X{
    X(){std::cout<<__func__<<std::endl;}
    ~X(){std::cout<<__func__<<std::endl;}
};

int main()
{
    X x;
}
```
実行結果は以下の通りです。
```cpp
X
~X
```
`main`関数内では、`X`型のオブジェクト`x`が生成されますが、その後なにもせずにスコープが終了します。よって、まず`X`型のオブジェクトが生成される段階で`X`のコンストラクタにより"X"という出力が、その後、スコープを終了する段階で`X`のデストラクタにより"~X"が出力されています。
このように、デストラクはオブジェクトが破棄されるタイミングで呼ばれます。
当然ですが、例えばオブジェクトをダイナミックに取得して破棄したとすれば、もちろんそのタイミングで呼ばれることとなります。
```cpp
#include<iostream>

struct X{
    X(){std::cout<<__func__<<std::endl;}
    ~X(){std::cout<<__func__<<std::endl;}
};

int main()
{
    X* x_ptr=new X();
    delete x_ptr;
    std::cout<<"bye"<<std::endl;
}
```
実行結果は以下の通りです。
```cpp
X
~X
bye
```
さて、デストラクタも同じように、暗黙定義される条件が...とは言わず、全ての場合において、デストラクタは暗黙定義されます。また、`default`、`inline`、`noexcept`などの指定が可能です。`constexpr`は、その特性から付与することはできません。また、デストラクタは、明示的に例外送出を指定しない限り、デフォルトで`noexcept`です。
```cpp
struct X{
    inline ~X()=default; // デフォルトデストラクタをinlineに
};
```

## 9.2.12 特殊メンバ関数、それに関わる用語とおさらい
ここまでで、コンストラクタ、コピーコンストラクタ、コピー代入演算子、ムーブコンストラクタ、ムーブ代入演算子、デストラクタといったものを説明してきました。
これらは、**特殊メンバ関数(specialize menber function)**と一括りにされています。
また、これまでに述べてきた`default`による定義は、**明示的なデフォルト定義 (explicity-defaulted definition)**と言われます。


## 9.2.13 関数のdelete宣言
ここまで、`default`によって明示的にデフォルト定義を行い、`inline`や`constexpr`などの指定が行えることを示してきました。
これらは、暗黙的に定義される特殊メンバ関数に対する所謂シンタックスシュガーといったもので、短くも明確にその動作の意味合いを表現するために導入された構文です。
さて、暗黙的に宣言される特殊なメンバ関数...今一度考えてみると、暗黙的に宣言しないでほしい場面というのがあるのではないか？！と思いませんでしょうか。
例えば、デフォルトコンストラクタを定義した場合、コピーコンストラクタとコピー代入演算子が暗黙定義されます。
しかし事例として、そのクラスから生成されたインスタンスのコピーを禁止したいといった場合、コピーとコピー代入操作は禁止されなければなりません。デフォルトコンストラクタを定義してしまったら、コピーコンストラクタとコピー代入演算子が暗黙的に定義されるせいで、それらの操作が許可されてしまうのです。
```cpp
struct NoCopyable{
    NoCopyable()=default; // explicity-defaulted definition
    // デフォルトコンストラクタによってコピーコンストラクタとコピー代入演算子が暗黙宣言される
};

int main()
{
    NoCopyable uq1;
    NoCopyable uq2=uq1; // この操作を禁止にしたい
}
```
さて、一体どうしましょうか。
ここで一つ考えられるのが、コピーコンストラクタとコピー代入演算子を、`private`アクセスレベル空間に宣言してしまうというものです。
```cpp
struct NoCopyable{
    NoCopyable()=default; // explicity-defaulted definition
private:
    NoCopyable(const NoCopyable&);
    NoCopyable& operator=(const NoCopyable&);
};

int main()
{
    NoCopyable uq1;
    NoCopyable uq2=uq1; // エラー！ 
}
```
プライベートアクセスレベルにあるメンバは、外部から呼び出すことはできない上、内部からも宣言のみで実態がないので、どこからも呼び出すことは不可能です。確かに、これで一件落着といったところでしょうか。
しかし、これはあまり明確なコードではないのです。何故ならば、上記のコードであれば、呼び出したくないコピーコンストラクタとコピー代入演算子の宣言のみですが、実際にはよりたくさんの他のメンバの宣言/定義がクラス内に含まれる場合も勿論あります。そのような場合に、果たしてこのコピーコンストラクタやコピー代入演算子が`private`アクセスレベル空間に宣言されているのは、意図してのことなのか、それとも何かの間違いなのかと、コードだけでは疑うことができてしまいます。確かにコメントなどを付与すればそれは伝わるかもしれませんが、コメントなどで補足しなくとも、文法的に意味を明快に示す事ができるのであれば、コンパイルのエラーメッセージの最適化にも役立つことから、それに越したことはないのです。
そこで、`delete`キーワードを使います。`delete`は動的に領域を確保する、`new`/`delete`の`delete`と全く同じキーワードですが、特定の構文上で使用することで、関数に対する`delete`指定であると認識されます。関数に対する`delete`指定は以下のように行います。
```cpp
struct NoCopyable{
    NoCopyable()=default;

    NoCopyable(const NoCopyable&)=delete;
    NoCopyable& operator=(const NoCopyable&)=delete;
};

int main()
{
    NoCopyable uq1;
    NoCopyable uq2=uq1; // エラー！    
    uq2=uq1; // エラー！
}
```
コード中のコメントでエラー！とある部分で、必ずコンパイルに失敗します。これは、`NoCopyable`クラスのコピーコンストラクタとコピー代入演算子を`delete`指定しているため、該当部分の呼び出しで削除された関数を呼び出そうとしているという旨のエラー文が出力されるはずです。
この方が`private`アクセスレベルに配置するよりも、ずっと意味合いが明確ですね。

尚、この関数にたいする`delete`指定は、上記のように特殊メンバ関数に対して用いる事が多いかもしれませんが、通常の関数に同じように指定ができます。
```cpp
void f()=delete; // 通常の関数に対してdelete指定
void f(int){} // 別のシグネチャはdelete指定されない

int main()
{
    f(); // エラー！ call to deleted function
    f(42); // OK
}
```
これは上記のように、特定のパラメータ型を持つオーバーロードの禁止を明示的に明確に示すために使う事ができます。

## 9.2.14 ちょっとしたdefaultに纏わる注意点
 
`default`指定について一つ注意したい点があります。
それは、`default`指定された事によって必ずしも、コンパイラが暗黙的にその該当する特殊メンバ関数を**定義するかどうか**は定かではないという事です。
例えば以下のようなコード
```cpp
struct X{
    constexpr X(int x=0):a(std::move(x)){}
    X& operator=(const X&)=default;
private:
    const int a;
};

int main()
{
    X x1=42,x2;
    x2=x1; // エラー！
}
```
これはコンパイルに失敗します。確かにコード中では`operator=`に対して`default`指定がされているのが分かります。よって、コンパイラが暗黙的にコピー代入演算子の定義を済ませてくれるかのように思えますが、残念ながらこれは動きません。
何故でしょうか。その答えば、メンバ変数`a`にあります。メンバ変数`a`は、`const`指定されています。`const`指定された変数を後から代入して変更することはできません。よって、この`operator=`は、このように`default`と明示的に指定し、コンパイラに暗黙宣言を促したとしても、コピー不可能なオブジェクトや変数を内部に抱えていた場合、実質この項の直後に説明する、`deleted`宣言されたようなものなのです。さらに少し厄介なのは、このコピー代入演算子を使わなかった場合です。
```cpp
#include<iostream>

struct X{
    constexpr X(int x=0):a(std::move(x)){}
    X& operator=(const X&)=default; // これを呼び出さない
private:
    const int a;
};

int main()
{
    [[maybe_unused]] X x1=42,x2;
}
```
このコードはコンパイルに成功してしまいます。`operator=`を使った途端、コンパイルに失敗してしまうことに気づけないかもしれません。
しかし、よくよく考えてみれば、この動作は当然のことなのです。内部にコピーできないデータを抱えていて、それら全体を覆うクラスがコピーできてしまえば、それは矛盾した動きになってしまいます。
このような点では、闇雲に`default`指定することはあまりよろしくないので、内部に持つメンバの特性をしっかり考えて記述することが大事です。

## 9.2.15 宣言と定義を分離する
ここまでの説明で、特殊メンバ関数は全て宣言と定義を同時に行なっていました。
しかし、特殊メンバ関数も、通常の関数と同じように宣言と定義を分離することが可能です。以下のように記述します。
```cpp
struct X{
    X(int=10); // 任意のコンストラクタを宣言
    X(const X&); // コピーコンストラクタを宣言
    X(X&&); // ムーブコンストラクタを宣言
    X& operator=(const X&); // コピー代入演算子を宣言
    X& operator=(X&&); // ムーブ代入演算子を宣言
    ~X(); // デストラクタを宣言
private:
    int a;
};

X::X(int x):a(std::move(x)){} // 任意のコンストラクタの定義

X::X(const X& other):a(other.a){} // コピーコンストラクタの定義

X& X::operator=(const X& other) // コピー代入演算子の定義
{
    a=other.a;
    return *this;
}

X& X::operator=(X&& other) // ムーブ代入演算子の定義
{
    a=std::move(other.a);
    return *this;
}

X::~X(){} // デストラクタの定義
```
このように、クラスの定義の外で各メンバ関数を定義することを**out-of-line definition**と言います。out-of-line definitionをする場合、定義したい各関数が何のクラスのものなのかを明示する必要がありますので、関数名の前に`X::`と付与しスコープ解決することで正しく定義が行えます。

out-of-line definitionには`default`指定を行う事もできます。
```cpp
struct X{
    X();
    X(const X&);
    X(X&&);
    X& operator=(const X&);
    X& operator=(X&&);
    ~X();
};

// defaultは、下記のように、宣言と分離する事ができる

X::X()=default;

X::X(const X&)=default;

X& X::operator=(const X&)=default;

X& X::operator=(X&&)=default;

X::~X()=default;
```
一方、`delete`をout-of-line definitionに指定することはできません。`delete`指定を行いたいのであれば前述の通り、関数の宣言部分に記述しなければなりません。
```cpp
// exp)コピーを禁止し、ムーブを許可するクラス
struct X{
    X();
    X(const X&)=delete;
    X(X&&);
    X& operator=(const X&)=delete;
    X& operator=(X&&);
    ~X();
};

X::X()=default;
X::X(X&&)=default;
X& X::operator=(X&&)=default;
X::~X()=default;
```

## 9.2.16 独自のメンバー関数

これまでで、コンストラクタ、デストラクタなどの特殊メンバ関数について述べてきましたが、この他にも、独自的に関数を宣言/定義することができます。特殊メンバ関数でない、クラス単位で宣言/定義された関数を**メンバ関数**と言います。
本項では、メンバ関数を宣言/定義、呼び出す方法を説明します。といっても、宣言や定義は通常の関数と殆ど変わりません。
```cpp
struct X{
    void f(){std::cout<<"X::f"<<std::endl;} // メンバ関数
};
```
`X`内に`f`というメンバ関数を定義しました。呼び出す時は、`.`演算子によってそのクラスのインスタンスから呼び出します。
```cpp
X x;
x.f(); // 呼び出し
X().f(); // rvalueからも呼び出せる
```
実行結果は以下となります。
```cpp
X::f
X::f
```
どちらの場合も呼び出せている事がわかると思います。
通常の関数通り、戻り値や引数、指定子を自由に付与できます。
```cpp
#include<iostream>

struct X{
    X(int x):a(x){}

    inline void f(){std::cout<<'f'<<std::endl;} // inline
    
    constexpr int plus(int r)noexcept // constexpr noexcept
    {
        return a+r;
    }
private:
    int a;
};

int main()
{
    X x(10);
    x.f();
    std::cout<<x.plus(10)<<std::endl;
}
```
実行結果は以下の通りです。
```cpp
f
20
```
通常の関数と同様、宣言と定義を分ける事ができます。定義時にはスコープ解決が必要です。
```cpp
#include<iostream>

struct X{
    X(int);
    inline void f();
    constexpr int plus(int)noexcept;
private:
    int a;
};

X::X(int x):a(x){} // ctor

inline void X::f(){std::cout<<__func__<<std::endl;}

constexpr int X::plus(int r)noexcept{return a+r;}

int main()
{
    X x(10);
    x.f();
    std::cout<<x.plus(10)<<std::endl;
}
```
実行結果は同じです。

通常の関数と同様、メンバ関数のポインターを宣言する事ができます。
```cpp
// クラスXの定義(上記と同様)

int main()
{
    void (X::*f_ptr)()=&X::f; // X::fへのポインター
    int (X::*plus)(int)noexcept=&X::plus; // X::plusへのポインター
}
```
型の記述法は少しややこしく感じるかもしれませんが、メンバ関数へのポインタを宣言する場合は上記のように、何のクラスのメンバ関数なのかを示してやる必要があります。それには、`::`によってスコープ解決をし、ポインタである`*`を記述し、その後宣言するポインターの識別子を定義します。
見ていただければ分かるように関数ポインタの場合と同じで、`noexcept`なメンバ関数に対するポインター型は、型名に`noexcept`を含める事ができます。`noexcept`なメンバ関数ポインタとして宣言しなくても構いませんが、特別な理由がない限り関数に合わせて付与した方が妥当でしょう。尚、通常の関数同様、`noexcept`でないメンバ関数へのポインタ型に`noexcept`を付与する事はできません。
```cpp
struct X{
    void f(){}
};

int main()
{
    void (X::*f_ptr)()noexcept=&X::f; // エラー！非noexceptな関数をnoexceptな関数ポインタで格納できない
}
```
さて、メンバ関数へのポインタをメンバ関数のアドレスを入れておく事ができたら、次は呼び出して見ましょう。呼び出しには、`.*`演算子と`->*`演算子を使います。
```cpp
// クラスXの定義(上記と同様)

int main()
{
    void (X::*f_ptr)()const=&X::f;
    int (X::*plus)(int)=&X::plus;

    X x(42);
    (x.*f_ptr)(); // 実オブジェクトxからメンバ関数ポインタを用いて呼び出し

    X* x_ptr=&x;
    std::cout<<(x_ptr->*plus)(42)<<std::endl; // xへのポインタからメンバ関数ポインタを用いて呼び出し
}
```
実行結果は以下の通りです。
```cpp
f
84
```
この時、`f_ptr()`のように呼び出すことはできません。メンバ関数ポインタは、そのクラスのインスタンスが指定されていないため、`(x.*f_ptr)()`というように、インスタンス(`x`)を指定しなければ、どのインスタンスからメンバ関数を呼び出すのか分からないためです。

## 9.2.17 thisポインター
突然ですが、以下のコードを見てください。
```cpp
#include<iostream>

struct X{
    int a=42;
    void f()
    {
        std::cout<<a<<std::endl;
    }
};

int main()
{
    X().f();
}
```
実行結果は以下の通りです。
```cpp
42
```
何を突然当然なことを、と思うかもしれませんが、少し一つだけ奇妙な点があるように思えませんでしょうか。メンバ関数`X::f`で、メンバ変数`a`を何事もなかったかのように使えています。
よくよく考えてみれば、関数スコープで囲まれている中から、その外側にあるメンバが見えるというのは、少し可笑しな挙動にも思えます。
さて、では何故このように今までメンバを自由にメンバ関数から使えていたかというと、実は、**メンバ関数を呼び出した時、そのメンバ関数に暗黙的に`this`ポインタが渡されていて、`this`ポインタによる関節アクセスを行なっているからです**。
何のことやらと思うかもしれませんが、そのまま以下のコードを読み進めてください。
```cpp
#include<iostream>
struct X{
    int a=42;
    void f()
    {
        std::cout<< this->a <<std::endl;
    }
};

int main()
{
    X().f();
}
```
このコードは正しいコードです。`this->a`という謎の記述が見受けられますね。ただ、`->`演算子を用いている事から、`this`がポインタであるという事は言えそうです。その通り、`this`はポインターです。しかし、この`this`というのはどこからやってきて、どのような機能を持っているのでしょうか。
まず、どこから来たのか、という疑問に対する答えは、**コンパイラによって暗黙的に渡されるため、プログラマがー明示的に示すものではない**といったところです。
次に、どのような機能を持っているかという疑問に対する答えは、**単なる自分自身(インスタンス)へのポインタというだけで、特別な機能はない**といったところです。
このように、メンバ関数を呼び出すと、暗黙的に`this`ポインタが渡される事になっています。そして、自身のメンバ変数である`a`へのアクセスは、全てこの`this`ポインタを経由して行われます。しかし、以下のように記述しても正しく動作する事はもう分かりきっています。
```cpp
struct X{
    int a=42;
    void f()
    {
        std::cout<< a <<std::endl; // thisを使っていない...?
    }
};
```
実は、このように`this`ポインタから関節参照を行なっている記述をせずとも、暗黙的に`this`ポインタを経由してメンバへのアクセスを行うのです。そのため、例えば上記の`a`へのアクセスで、`this`ポインタを記述しているコードと、`this`ポインタを記述していないコードは、全く同じ動作をするのです。何気なく、メンバ関数内で同クラス内のメンバ変数に対してアクセスしていましたが、実際のアクセスは全て`this`ポインタを経由してアクセスしています。

さて、このthisポインタ、一体何に使えるのでしょうか。実際は様々な部分部分で使えるのですが、最も使うシーンは、前述したような代入演算子の定義の最後で、自分自身を返却する場合でしょう。
```cpp
struct X{
    X& operator=(const X&)
    {
        // do assign and etc...
        return *this; // 自分自身を返却する
    }
};
```
代入演算子で自分自身を返却する理由は、連続的な代入記述を実現するためです(詳しくは前述した代入演算子についての項を見てください)。

他の例で言えば、例えば仮引数名とメンバ名が同一である時に、どちらが仮引数の値でどちらが自分自身に所属するメンバなのかを明示する場合などがあります。
```cpp
struct X{
    void f(int a)
    {
        a /* 仮引数aに対する操作... */ ;
        this->a /* メンバ変数aに対する操作 ... */ ;
    }
    int a;
};
```

## 9.2.18 メンバ関数のCV、lvalue/rvalue修飾

メンバ関数に対して、CV修飾(`const`/`volatile`)、lvalue/rvalueの修飾を付与する事ができます。どういう事かというと、まず以下のコードを見て見ましょう。
```cpp
struct X{
    void f()const{}
    void f()volatile{}
    void g()&{}
    void g()&&{}
};
```
上記のように、関数の引数の`()`の前に`const`、`volatile`、lvauleを表す`&`、rvalue`を表す`&&`を付与します。これらを付与する事によって、それぞれどのような効果があるのか、それぞれ説明していきます。

### const修飾
メンバ関数に`const`修飾をする事によって、そのメンバ関数呼び出しによって呼び出し元のオブジェクトのデータが変更されない事を明示します。
```cpp
#include<iostream>

struct X{
    explicit constexpr X(int x):a(x){}
    void disp_a()const{std::cout<<a<<std::endl;} // disp_aはメンバ変数のデータを変更しない
private:
    int a;
};

int main()
{
    X x(42);
    x.disp_a();
}
```
`const`修飾されたメンバ関数は、メンバのデータを変更する操作行う事はできません。
よって、以下のコードは正しくありません。
```cpp
struct X{
    explicit constexpr X(int x):a(x){}
    void f(int x)const{a=x;} // constメンバ関数で内部のデータメンバのデータを変更できない
private:
    int a;
};

int main()
{
    X x(42);
    x.f(50);
}
```
また、`const`修飾されたメンバ関数と、`const`修飾されていないメンバ関数はオーバーロードする事ができます。これらは、呼び出したオブジェクトそのものが`const`であるか否かで呼び分けられます。
```cpp
#include<iostream>

struct X{
    void f()const{std::cout<<"const "<<__func__<<std::endl;}
    void f(){std::cout<<"non-const "<<__func__<<std::endl;}
};

int main()
{
    X x1;
    x1.f();

    const X x2{};
    x2.f();
}
```
実行結果は以下となります。
```cpp
non-const f
const f
```
現時点ではまだ気にする必要はありませんが、`const`修飾されたメンバ関数に対して理想的な動作とは、該当メンバ関数の呼び出しを行っても**スレッドセーフ**であるという事です。(スレッドセーフである事とは、大まかに言えば競合が発生しないという要件であるため、`disp_a`は確かにスレッドセーフな関数です。しかし、`std::cout`への出力はスレッドセーフであるものの、大抵の場合その出力したい変数一つ一つを正しく出力したいのでしょうから、その要件を満たせてはいない点を考慮すると、別途適切な排他制御が必要でしょう。)

### volatile修飾
ここまでで、まず`volatile`について説明していませんでした。`volatile`は主にコンパイラの最適化を抑止するキーワードです。
最適化は、例えば以下のようなコードで行われる場合があります。
```cpp
int i=42;

i=52;
i=62;
i=72;
```
この処理を終えた後、最終的な`i`の値は72です。しかし、他のスレッドとの何らかの関係性があった場合、このコードに値が代入されていく過程は、そのまま忠実に再現されていなければならない場合もあるのです。
しかし、コンパイラは、最適化の結果によっては、最後の`i=72`という文のみを残してそれ以外の代入文を排除したアセンブリコードを生成する事があります。前述した通り、この過程が忠実に実行されなければならない場合において、このような最適化が行われてしまって困ります。
このような場合に、`volatile`キーワードを使う事で最適化を抑止します。
```cpp
volatile int i=42;

// iへの操作...
```
もう一つ最適化の可能性が考えられる例を挙げておきましょう。
以下のコードは、最適化される可能性があります。
```cpp
int d=0;

for(int i=0; i<1000; ++i)
    d=++i;
// 以降dを一切しようしない
```
最終的な結果として、`d`の値を一切使わないのであれば、`d`に関する操作は全くの無駄であると考えられるため、最適化によってはこの`for`ループごと削除してしまうかもしれません。しかし、この`for`ループはwaitやsleepのような一時的に処理を停止させるためのループかもしれません。そういった用途として必要である場合、削除されてしまうと困ります。この場合、以下のように`volatile`を付与する事で最適化を抑止します。
```cpp
volatile int d=0;

// forループ...
```
`volatile`に関する最適化の概念の一つとしてstrict aliasルールというものがあります。strict aliasルールについては、コラムで取り上げています。


さて、`volatile`修飾されたメンバ関数の話に戻ります。`volatile`修飾されたメンバ関数は、`const`の場合と同じく、関数全体に影響を与え、呼び出し元とのオーバーロードを実現します。具体的には、`volatile`修飾されたメンバ関数はその関数が丸ごと最適化処理の抑制が指定でき、`volatile`なオブジェクトとそうでないオブジェクトの呼び分けが可能だという事です。
```cpp
#include<iostream>

struct X{
    void f()volatile{std::cout<<"volatile "<<__func__<<std::endl;}
    void f(){std::cout<<"non-volatile "<<__func__<<std::endl;}
};

int main()
{
    X x1;
    x1.f();

    volatile X x2;
    x2.f();
}
```
実行結果は以下の通りです。
```cpp
non-volatile f
volatile f
```

### lvalue修飾
lvalue修飾は、オブジェクトがlvalueである場合に呼び出される修飾です。
```cpp
#include<iostream>

struct X{
    void f()&{std::cout<<"lvalue "<<__func__<<std::endl;}
};

int main()
{
    X x1;
    x1.f();
}
```
実行結果は以下の通りです。
```cpp
lvalue f
```
この時、上記のメンバ関数`X::f`をrvalueのオブジェクトから呼び出す事はできません。
```cpp
#include<iostream>

struct X{
    void f()&{std::cout<<"lvalue "<<__func__<<std::endl;}
};

int main()
{
    X().f(); // エラー！rvalueからlvalue修飾されたメンバ関数を呼び出す事はできない
}
```
また、lvalue修飾されたメンバ関数と、何も修飾していないメンバ関数は、オーバーロード解決が曖昧になるため、呼び分ける事はできません。
```cpp
#include<iostream>

struct X{
    void f()&{std::cout<<"lvalue "<<__func__<<std::endl;}
    void f(){std::cout<<"simply "<<__func__<<std::endl;}
};

int main()
{
    X x;
    x.f(); // エラー！どちらも呼ぶ事ができるためオーバーロード解決が曖昧
}
```

### rvalue修飾
rvalue修飾は、オブジェクトがrvalueである場合に呼び出される修飾です。
```cpp
#include<iostream>

struct X{
    void f()&&{std::cout<<"rvalue "<<__func__<<std::endl;}
};

int main()
{
    X().f();
}
```
実行結果は以下の通りです。
```cpp
rvalue f
```
この時、上記のメンバ関数`X::f`をlvalueのオブジェクトから呼び出す事はできません。
```cpp
#include<iostream>

struct X{
    void f()&&{std::cout<<"rvalue "<<__func__<<std::endl;}
};

int main()
{
    X x;
    x.f(); // エラー！lvalueからrvalue修飾されたメンバ関数を呼び出す事はできない
}
```
また、rvalue修飾されたメンバ関数と、何も修飾していないメンバ関数は、オーバーロード解決が曖昧になるため、呼び分ける事はできません。
```cpp
#include<iostream>

struct X{
    void f()&&{std::cout<<"rvalue "<<__func__<<std::endl;}
    void f(){std::cout<<"simply "<<__func__<<std::endl;
};

int main()
{
    X().f(); // エラー！どちらも呼び出す事ができるためオーバーロード解決が曖昧
}
```

### 修飾の組み合わせ
尚、これらの修飾は組み合わせる事ができます。
```cpp
#include<iostream>

struct X{
    void f()const &
    {
        std::cout<<"const lvalue "<<__func__<<std::endl;
    }
    void f()const volatile &&
    {
        std::cout<<"const volatile rvalue "<<__func__<<std::endl;
    }
};

int main()
{
    X x;
    x.f(); // const lvalueなメンバ関数fを呼び出す。constではないがlvalueとrvalueで呼び出し可能なメンバ関数から呼び分けられる。
    X().f(); // const volatile rvalueなメンバ関数fを呼び出す。volatileではないが、lvalueとrvalueではないが、lvalueとrvalueで呼び分けられる。
}
```
実行結果は以下の通りです。
```cpp
const lvalue f
const volatile rvalue f
```
呼び出している両者はそれぞれ`const`なオブジェクトでも、`volatile`なオブジェクトでもありませんが、このように呼び出しが可能なメンバ関数が呼び出されます。

## 9.2.19 内部クラス
クラス内にクラスを定義する事も可能です。
```cpp
struct X{
    struct Y{}; // 内部クラス
};
```
内包されたクラス`Y`をインスタンス化する場合、以下のように名前解決を行います。
```cpp
X::Y y;
```
ただ、内部クラスは、殆どの場合、自身を内包する外側のクラスと動作の中で密接な関係がある場合に用いる事が多いです。
また、内部クラスは自身を内包する外側のクラスの`private`アクセスレベルのデータメンバにアクセスする事ができます。
```cpp
#include<iostream>

struct X{
    X(int a=42):a_(std::move(a)){} 
    struct Y{
        void assign_a(X& x,int as)
        {
            x.a_=as; // Xのプライベートメンバ変数a_にアクセス
        }
    }y;

    constexpr int get()const noexcept{return a_;}
private:
    int a_;
};

int main()
{
    X x;
    x.y.assign_a(x,52);
    std::cout<<x.get()<<std::endl;
}
```
実行結果は以下の通りです。
```cpp
52
```
なお、内部クラスは、宣言と定義を分離することはできません。