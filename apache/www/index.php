<?php
  echo "<pre><h2>Apache+PHP Container Running</h2></pre><br/>";
  mysqli_connect("mysql", "root", "12345") or die(mysqli_error()); 
  echo "<pre><h3>Connected to MySQL<h3></pre><br/>";
?>
