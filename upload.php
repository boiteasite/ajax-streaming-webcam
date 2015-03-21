<?php
	//
	if ($_POST && $_POST['image'])
		{
		$im = str_replace(" ","+",strip_tags($_POST['image']));
		$im = substr($im, 1+strrpos($im, ','));
		if (strip_tags($_POST['id']))
			{
			file_put_contents("webcam/web".strip_tags($_POST['id']).".jpg", base64_decode($im));
		//	file_put_contents("webcam/web".strip_tags($_POST['id']).".txt", "data:image/jpeg;base64,".$im);
			}
		}
//	else if ($_GET && $_GET['id']) echo file_get_contents('webcam/web'.strip_tags($_GET['id']).'.txt');
	//
?>
