case XCHG:
					// MAR = MEMORY[PC];
					// PC++;
					selM1 = sPC;
					RW = 0;
					LoadMAR = 1; 
                    selM4 = rx; // move o conteudo do rx
					LoadMBR = 1; // para o MBR
					IncPC = 1;
					// -----------------------------
					state=STATE_EXECUTE;
					break;


case XCHG:
					//reg[rx] = MEMORY[MAR];
					selM1 = sMAR;
					RW = 0;
					selM2 = sDATA_OUT;
					LoadReg[rx] = 1; // manda o conteudo da mem p ry
					// -----------------------------
					state=STATE_EXECUTE2;
					break;

case XCHG:
					//MEMORY[MAR] = reg[rx];
					selM1 = sMAR;
					RW = 1;
					selM5 = sMBR;
					// -----------------------------
					state=STATE_FETCH;
					break; 



					//montador

					case XCHG_CODE :

					str_tmp1 = parser_GetItem_s();
                    val1 = BuscaRegistrador(str_tmp1);
                    free(str_tmp1);
                    parser_Match(',');
                    val2 = RecebeEndereco();
                    str_tmp1 = ConverteRegistrador(val1);
                    str_tmp2 = NumPBinString(val2);
                    sprintf(str_msg,"%s%s0000000",XCHG,str_tmp1);
                    parser_Write_Inst(str_msg,end_cnt);
                    end_cnt += 1;
                    sprintf(str_msg,"%s",str_tmp2);
                    parser_Write_Inst(str_msg,end_cnt);
                    end_cnt +=1;
                    free(str_tmp1);
                    free(str_tmp2);
                    break;