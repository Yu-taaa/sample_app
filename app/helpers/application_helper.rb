module ApplicationHelper
  #Railsでは自動的にヘルパーモジュールを読み込んでくれるので、include行をわざわざ書く必要がない
  #つまり、このfull_titleメソッドは自動的にすべてのビューで利用できるようになっている
  # ページごとの完全なタイトルを返します。
  #(page_title = '')は、本引数がなければ、page_titleの初期値を「''」とする記述
  def full_title(page_title = '')
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end
end