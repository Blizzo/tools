#making a file immunable

read -p "File location: " FILE
read -p "Do you want to +i or -i? " OPTION

#adding the +i
if [ $OPTION -eq "+i" ]
   then
      sudo chattr +i $FILE
      echo "Added +i to $FILE"
      chmod 000 $FILE
      
#removing the -i
elif [ $OPTION -eq "-i" ]
   then
      sudo chattr -i $FILE
      echo "Added -i to $FILE"
      chmod 700 $FILE

#else, fail
else
   echo "Failure."

fi
