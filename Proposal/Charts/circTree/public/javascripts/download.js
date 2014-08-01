var canvas = document.querySelector("canvas"),
    context = canvas.getContext("2d");

var image = new Image;
image.src = "img.svg";
image.onload = function() {
  canvas.setAttribute("width", image.width*4);
  canvas.setAttribute("height", image.height*4);
  context.drawImage(image, 0, 0, image.width*4, image.height*4);

  var a = document.createElement("a");
  a.download = "img.png";
  a.href = canvas.toDataURL("image/png");
  a.click();
};