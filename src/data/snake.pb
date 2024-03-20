

file = ReadFile(0,"ZXNEXT_64x64.raw")

If file 
  length_of_data = Lof(0)
  *buffer = AllocateMemory(length_of_data)
  *output = AllocateMemory(length_of_data)
Else
  End 
EndIf 

snake_width = 64
If file 
  ReadData(0,*buffer,length_of_data)     ; 4096
  
  position = 0 
  
  Repeat
    
    For x = position To position+snake_width     ; first line 
      a=PeekA(*buffer+x)
      PokeA(*output+x,a)
    Next x 
    
    position + snake_width 
    endset = 0
    For x = position To position+snake_width     ; first line 
      a=PeekA(*buffer+x)
      PokeA((*output+position)+(snake_width-endset),a)
      endset + 1 
    Next x 
    
    position + snake_width
    
  Until position = length_of_data
  
  Debug "done" 
  
  If CreateFile(1,"ZXNEXT_64x64.snk")
    WriteData(1,*output,length_of_data)
    Debug "saved"
    CloseFile(1)
  EndIf
  CloseFile(0)
  
  FreeMemory(*buffer)
  FreeMemory(*output)
  
Else
  Debug "failed to open file "
EndIf 
; IDE Options = PureBasic 6.00 Beta 10 (Windows - x64)
; CursorPosition = 12
; EnableXP
; DPIAware