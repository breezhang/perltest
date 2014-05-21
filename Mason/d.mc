<body>
    %if($contents||$allow_empty) {
      <ul>
    %foreach my $line (@lines) {
    %chomp($line);
      <li>
          <%2+(3-4)*6%>
      </li>
      <li><%  foo($.bar,$.baz,  $.bleah)%></li>
    %}
      </ul>
    %}
    </body>
    
    <%init>
    my @articles = @{Blog::Article::Manager->get_articles(sort_by=>"create_time",limit=>5)};
    </%init>  
