main(){
  
  String? name;
  
  print(name);
  print(name?.length);
  print(name?? " Guest");
  
  name ??= " Guiest 2";
  print(name);
  print(name!.length);

  //https://dartpad.dev/

}