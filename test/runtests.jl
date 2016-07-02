using PromiseExtractor
using Base.Test

# write your own tests here
@test 1 == 1

@test promise_for("""
<html>
  <head>
    <link rel="stylesheet" type="text/css" href="example.css">
  </head>
  <body>
    <div>
      <p></p> <a></a> <p></p>
      <img src="http://localhost/example.jpg">
    </div>
    <div>
       <span></span>
    </div>
    <script src="example.js"></script>
   </body>
</html>
""", "http://localhost") == ["example.css","http://localhost/example.jpg","example.js"]
