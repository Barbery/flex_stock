package components
{

	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import flashx.textLayout.formats.Float;
	
	import mx.controls.Alert;

	/**
	 * 功能：解压数据
	 * @author Barbery
	 * @contact Email:380032007@qq.com
	 */

	public class Decompress
	{
		private static var _instance:Decompress;
		public function Decompress()
		{
		}
		
		public static function getInstance():Decompress {  
			if(_instance == null) {  
				_instance = new Decompress();  
			}
			return _instance;  
		}  
		
		/**
		 * 获取解压后的K线数据 
		 * @param Cycle K线数据的周期
		 * @param Code 股票代码
		 * @param Count k线数据个数
		 * @param pData 未解压的K线数据
		 * @return 返回解压后的K线
		 * 
		 */		
		
		public function getKline(Cycle:int , Code:int , Count:uint , pData:ByteArray ):Array
		{
			pData.endian = Endian.LITTLE_ENDIAN;
			if( Count <= 0 )
			{
				return [];
			}
			
			var TimeCycle:int = 0;
			switch( Cycle )
			{
				case 11:
				case 12:
				case 13:
				case 14:
				case 15:
					TimeCycle = 86400;
					break;
				case 3:
				case 4:
				case 5:
				case 6:
				case 7:
				case 8:
				case 9:
				case 10:
					TimeCycle = 60;
					break;
				default:
					return [];
			}
			
			var BlockType:int = GetBlockType( Code );
			if(BlockType == 5 || BlockType == 3 || BlockType == 12 || BlockType == 10){
				Times = 10000;
			}
			var Times:Number = 2000;
			var pKline:Array = [];
			var ChangeBit:uint;
			
			ChangeBit = pData.readUnsignedInt();
			
			var TimeMask:uint = ((ChangeBit & (0x3 << 0)) >> 0) + 1;
			var OpenMask:uint = ((ChangeBit & (0x3 << 2)) >> 2) + 1;
			var HighMask:uint = ((ChangeBit & (0x3 << 4)) >> 4) + 1;
			var LowMask:uint = ((ChangeBit & (0x3 << 6)) >> 6) + 1;
			var CloseMask:uint = ((ChangeBit & (0x3 << 8)) >> 8) + 1;

			pKline.push( {"Date": pData.readInt()*1000 , "Open": pData.readFloat() , "High": pData.readFloat() , "Low": pData.readFloat() , "Close": pData.readFloat() , "Vol": pData.readFloat() , "Amount": pData.readFloat() } );
			
			
			var BufDif:int;
			var pNegMask:Array=[];
			pNegMask[0] = (1 << (((TimeMask - 1) << 3) + 7));
			pNegMask[1] = (1 << (((OpenMask - 1) << 3) + 7));
			pNegMask[2] = (1 << (((HighMask - 1) << 3) + 7));
			pNegMask[3] = (1 << (((LowMask - 1) << 3) + 7));
			pNegMask[4] = (1 << (((CloseMask - 1) << 3) + 7));
			
			var pRecovMask:Array=[];
			pRecovMask[1] = 0xffffff00;
			pRecovMask[2] = 0xffff0000;
			pRecovMask[3] = 0xff000000;
			pRecovMask[4] = 0x00000000;
			
			var i:int = 0;
			var byte:ByteArray = new ByteArray();
			
			
			if(TimeMask >= 4){
				for(i = 1 ; i < Count ; ++i){
					pKline[i] = [];
					pKline[i].Date = pData.readInt()*1000;
				}
			}
			else{
				for(i = 1 ; i < Count ; ++i){
					BufDif = 0;
					pKline[i] = [];
					pData.readBytes( byte , 0 , TimeMask);
					for( var k:int = 0 ; k < TimeMask ; k++){
						BufDif += byte[k] * Math.pow(256 , k);
					}
					
					if(BufDif & pNegMask[0]){
						BufDif |= pRecovMask[TimeMask]; 
					}
					pKline[i].Date = pKline[i - 1].Date + (BufDif * TimeCycle)*1000;
				}
			}
			
			if(OpenMask >= 4){
				for(i = 1 ; i < Count ; ++i){
					pKline[i].Open = pData.readFloat();
				}
			}
			else{
				for(i = 1 ; i < Count ; ++i){
					BufDif = 0;
					pData.readBytes( byte , 0 , OpenMask);
					for( k = 0 ; k < OpenMask ; k++){
						BufDif += byte[k] * Math.pow(256 , k);
					}
					if(BufDif & pNegMask[1]){
						BufDif |= pRecovMask[OpenMask]; 
					}
					pKline[i].Open =  (pKline[i - 1].Open +BufDif / Times);
				}
			}
			
			if(HighMask >= 4){
				for(i = 1 ; i < Count ; ++i){
					pKline[i].High = pData.readFloat();
				}
			}
			else{
				for(i = 1 ; i < Count ; ++i){
					BufDif = 0;
					pData.readBytes( byte , 0 , HighMask);
					for( k = 0 ; k < HighMask ; k++){
						BufDif += byte[k] * Math.pow(256 , k);
					}
					if(BufDif & pNegMask[2]){
						BufDif |= pRecovMask[HighMask]; 
					}
					pKline[i].High =  pKline[i - 1].High +BufDif / Times;
				}
			}
			
			if(LowMask >= 4){
				for(i = 1 ; i < Count ; ++i){
					pKline[i].Low = pData.readFloat();
				}
			}
			else{
				for(i = 1 ; i < Count ; ++i){
					BufDif = 0;
					pData.readBytes( byte , 0 , LowMask);
					for( k = 0 ; k < LowMask ; k++){
						BufDif += byte[k] * Math.pow(256 , k);
					}
					if(BufDif & pNegMask[3]){
						BufDif |= pRecovMask[LowMask]; 
					}
					pKline[i].Low = pKline[i - 1].Low +BufDif / Times;
				}
			}
			
			if(CloseMask >= 4){
				for(i = 1 ; i < Count ; ++i){
					pKline[i].Close = pData.readFloat();
				}
			}
			else{
				for(i = 1 ; i < Count ; ++i){
					BufDif = 0;
					pData.readBytes( byte , 0 , CloseMask);
					for( k = 0 ; k < CloseMask ; k++){
						BufDif += byte[k] * Math.pow(256 , k);
					}
					if(BufDif & pNegMask[4]){
						BufDif |= pRecovMask[CloseMask]; 
					}
					pKline[i].Close = pKline[i - 1].Close +BufDif / Times;
				}
			}
			
			var ma5:Number = pKline[0]["Ma5"] = pKline[0]["Close"];
			var ma10:Number = pKline[0]["Ma10"] = pKline[0]["Close"];
			var ma20:Number = pKline[0]["Ma20"] = pKline[0]["Close"];
			var ma30:Number = pKline[0]["Ma30"] = pKline[0]["Close"];
			var vol5:Number = pKline[0]["Vol5"] = pKline[0]["Vol"];
			var vol10:Number = pKline[0]["Vol10"] = pKline[0]["Vol"];
			var vol20:Number = pKline[0]["Vol20"] = pKline[0]["Vol"];
			
			for(i = 1 ; i < Count ; ++i){
				pKline[i].Vol = pData.readFloat();
				
				if( i < 5 )
				{
					ma5 += pKline[i].Close;
					pKline[i].Ma5 =  ma5 / ( i+1 ) ;
					
					vol5 += pKline[i].Vol;
					pKline[i].Vol5 =  vol5 / ( i+1 )  ;
				}
				else
				{
					ma5 = ma5 + pKline[i].Close - pKline[i-5].Close;
					pKline[i].Ma5 =  ma5 /5 ;
					
					vol5 = vol5 + pKline[i].Vol - pKline[i-5].Vol;
					pKline[i].Vol5 = vol5 /5 ;
				}
				
				if( i < 10 )
				{
					ma10 += pKline[i]["Close"];
					pKline[i]["Ma10"] = ma10 / ( i + 1 );
					
					vol10 += pKline[i]["Vol"];
					pKline[i]["Vol10"] = vol10 / ( i + 1 );
				}
				else
				{
					ma10 = ma10 + pKline[i]["Close"] - pKline[i-10]["Close"];
					pKline[i]["Ma10"] = ma10 / 10;
					
					vol10 = vol10 + pKline[i]["Vol"] - pKline[i-10]["Vol"];
					pKline[i]["Vol10"] = vol10 / 10 ;
				}
				
				if( i < 20 )
				{
					ma20 += pKline[i]["Close"];
					pKline[i]["Ma20"] = ma20 / ( i + 1 );
					
					vol20 += pKline[i]["Vol"];
					pKline[i]["Vol20"] = vol20 / ( i + 1 ) ;
				}
				else
				{
					ma20 = ma20 + pKline[i]["Close"] - pKline[i-20]["Close"];
					pKline[i]["Ma20"] = ma20 / 20 ;
					
					vol20 = vol20 + pKline[i]["Vol"] - pKline[i-20]["Vol"];
					pKline[i]["Vol20"] = vol20 / 20 ;
				}
				
				if( i < 30 )
				{
					ma30 += pKline[i]["Close"];
					pKline[i]["Ma30"] = ma30 / ( i + 1 ) ;
				}
				else
				{
					ma30 = ma30 + pKline[i]["Close"] - pKline[i-30]["Close"];
					pKline[i]["Ma30"] = ma30 / 30 ;
				}

			}
			
			for(i = 1 ; i < Count ; ++i){
				pKline[i].Amount = pData.readFloat();
			}
			
			return pKline;
			
		}
		
		
		/*
		enum E_MoFormulaType{
		ftInvalid = 0,
		ftVol,
		ftAmount,
		ftMA,
		ftKDJ,
		ftMACD,
		ftBIAS,
		ftZNFZ,
		ftBDW,
		ftZLZZ,
		ftLargeDeal,
		ftMidDeal, 
		ftSmallDeal,
		ftBLZZ,
		ftJJCC, //基金持仓
		ftSHSL, //散户数量
		ftZLZJ, //主力增减
		ftSHZJ, //散户增减
		ftZLKP, //主力控盘
		ftKPYK, //控盘盈亏
		ftVirtualVOL, //虚拟成交量
		ftQLFT, //潜龙飞天
		ftSSTP, //水手突破
		ftRSI, //RSI
		ftEnd,
		};
		*/

		/**
		 * 功能：解压分时线
		 * @param Code 股票代码
		 * @param Count 分时线数据量
		 * @param pData 未解压的字符流
		 * @return 返回解压后的数组
		 * 
		 */		
		
		public function getFSline ( Code:int , Count:uint , pData:ByteArray ):Array
		{
			if(Count == 0){
				return [];
			}
			var TimeCycle:int = 60;
			var Times:Number = 100;
			var BlockType:int = GetBlockType( Code );
			if(BlockType == 5 || BlockType == 3 || BlockType == 12 || BlockType == 10){
				Times = 1000;
			}
			
			
			var ChangeBit:uint = pData.readUnsignedInt();

			var TimeMask:uint = ((ChangeBit & (0x3 << 0)) >> 0) + 1;
			var PriceMask:uint = ((ChangeBit & (0x3 << 2)) >> 2) + 1;
			var VolMask:uint = ((ChangeBit & (0x3 << 4)) >> 4) + 1;
			var AmountMask:uint = ((ChangeBit & (0x3 << 6)) >> 6) + 1;

			var result:Array = [];
			result.push({ 'Time':pData.readInt()*1000 , 'Price':pData.readFloat() , 'Vol':pData.readFloat() , 'Amount':pData.readFloat()  });
			
			var BufDif:int;
			var pNegMask:Array = [];
			pNegMask[0] = (1 << (((TimeMask - 1) << 3) + 7));
			pNegMask[1] = (1 << (((PriceMask - 1) << 3) + 7));
			pNegMask[2] = (1 << (((VolMask - 1) << 3) + 7));
			pNegMask[3] = (1 << (((AmountMask - 1) << 3) + 7));
			var pRecovMask:Array = [];
			pRecovMask[1] = 0xffffff00;
			pRecovMask[2] = 0xffff0000;
			pRecovMask[3] = 0xff000000;
			pRecovMask[4] = 0x00000000;
			
			
			var i:int;
			var byte:ByteArray = new ByteArray();
			var max:Number = result[0]['Price'];
			var min:Number = max;
			
			if(TimeMask >= 4){
				for(i = 1 ; i < Count ; ++i){
					result[i] = [];
					result[i]['Time'] = pData.readInt()*1000;
				}
			}
			else{
				for(i = 1 ; i < Count ; ++i){
					result[i] = [];
					BufDif = 0;
					pData.readBytes( byte , 0 , TimeMask);
					for( var k:int = 0 ; k < TimeMask ; ++k){
						BufDif += byte[k] * Math.pow(256 , k);
					}
					if(BufDif & pNegMask[0]){
						BufDif |= pRecovMask[TimeMask]; 
					}
					result[i]["Time"] = result[i - 1]["Time"] + (BufDif * TimeCycle)*1000;
				}
			}
			
			var avg:Number = result[0]['AvgPrice'] = result[0]['Price'];
			if(PriceMask >= 4){
				for(i = 1 ; i < Count ; ++i){
					result[i]['Price'] = pData.readFloat();
					max = Math.max( max , result[i]['Price'] );
					min = Math.min( min , result[i]['Price']);
					avg += result[i]['Price'];
					result[i]['AvgPrice'] = avg / (i+1) ;
				}
			}
			else{
				for(i = 1 ; i < Count ; ++i){
					BufDif = 0;
					pData.readBytes( byte , 0 , PriceMask);
					for( k = 0 ; k < PriceMask ; ++k){
						BufDif += byte[k] * Math.pow(256 , k);
					}
					if(BufDif & pNegMask[1]){
						BufDif |= pRecovMask[PriceMask]; 
					}
					result[i].Price = result[i - 1].Price +  BufDif / Times;
					max = Math.max( max , result[i]['Price'] );
					min = Math.min( min , result[i]['Price']);
					avg += result[i]['Price'];
					result[i]['AvgPrice'] = avg / (i+1) ;
				}
			}
			result[0]['max'] = max;
			result[0]['min'] = min;
			
			var volCount:Number = result[0]['Vol'];
			if(VolMask >= 4){
				for(i = 1 ; i < Count ; ++i){
					result[i]['Vol'] = pData.readFloat() - volCount;
					volCount +=result[i]['Vol'];
				}
			}
			else{
				for(i = 1 ; i < Count ; ++i){
					BufDif = 0;
					pData.readBytes( byte , 0 , VolMask);
					for( k = 0 ; k < VolMask ; ++k){
						BufDif += byte[k] * Math.pow(256 , k);
					}
					if(BufDif & pNegMask[2]){
						BufDif |= pRecovMask[VolMask]; 
					}
					result[i]['Vol'] =  BufDif;
				}
			}
			
			var amountCount:Number = result[0]['Amount'];
			if(AmountMask >= 4){
				for(i = 1 ; i < Count ; ++i){
					result[i]['Amount'] = pData.readFloat() - amountCount;
					amountCount += result[i]['Amount'];
				}
			}
			else{
				for(i = 1 ; i < Count ; ++i){
					BufDif = 0;
					pData.readBytes( byte , 0 , AmountMask);
					for( k = 0 ; k < AmountMask ; ++k){
						BufDif += byte[k] * Math.pow(256 , k);
					}
					if(BufDif & pNegMask[3]){
						BufDif |= pRecovMask[AmountMask]; 
					}
					result[i]['Amount'] = BufDif;
				}
			}
			
			return result;
		}
		
		/**
		 * 功能：获取解压后的分笔数据。
		 * @param Code 股票代码
		 * @param Count 分笔数据量
		 * @param pData 为解压的bytearray
		 * @return 返回解压后的分笔数据
		 * 
		 */
		
		public function getFBdata ( Code:int , Count:uint , pData:ByteArray ):Array
		{
			if(Count == 0){
				return [];
			}

			var TimeCycle:int = 1;
			var Times:Number = 100;
			var BlockType:int = GetBlockType( Code );
			if(BlockType == 5 || BlockType == 3 || BlockType == 12 || BlockType == 10){
				Times = 1000;
			}
			
			var ChangeBit:uint = pData.readUnsignedInt();
			
			var TimeMask:uint = ((ChangeBit & (0x3 << 0)) >> 0) + 1;
			var PriceMask:uint = ((ChangeBit & (0x3 << 2)) >> 2) + 1;
			var VolMask:uint = ((ChangeBit & (0x3 << 4)) >> 4) + 1;
			var AmountMask:uint = ((ChangeBit & (0x3 << 6)) >> 6) + 1;
			
			var result:Array = [];
			result.push({ 'Time':pData.readInt()*1000, 'Price':pData.readFloat(), 'Vol':pData.readFloat(), 'Amount':pData.readFloat()	});
			
			
			var BufDif:int;
			var pNegMask:Array = [];
			pNegMask[0] = (1 << (((TimeMask - 1) << 3) + 7));
			pNegMask[1] = (1 << (((PriceMask - 1) << 3) + 7));
			pNegMask[2] = (1 << (((VolMask - 1) << 3) + 7));
			pNegMask[3] = (1 << (((AmountMask - 1) << 3) + 7));
			var pRecovMask:Array = [];
			pRecovMask[1] = 0xffffff00;
			pRecovMask[2] = 0xffff0000;
			pRecovMask[3] = 0xff000000;
			pRecovMask[4] = 0x00000000;
			
			var i:int;
			var byte:ByteArray = new ByteArray();
			
			if(TimeMask >= 4){
				for(i = 1 ; i < Count ; ++i){
					result[i] = [];
					result[i]['Time'] = pData.readInt()*1000;
				}
			}
			else{
				for(i = 1 ; i < Count ; ++i){
					result[i] = [];
					BufDif = 0;
					pData.readBytes( byte , 0 , TimeMask);
					for( var k:int = 0 ; k < TimeMask ; ++k){
						BufDif += byte[k] * Math.pow(256 , k);
					}
					if(BufDif & pNegMask[0]){
						BufDif |= pRecovMask[TimeMask]; 
					}
					result[i]["Time"] = result[i - 1]["Time"] + (BufDif * TimeCycle)*1000;
				}
			}
			
			if(PriceMask >= 4){
				for(i = 1 ; i < Count ; ++i){
					result[i]['Price'] = Math.round(pData.readFloat()*100)/100;
				}
			}
			else{
				for(i = 1 ; i < Count ; ++i){
					BufDif = 0;
					pData.readBytes( byte , 0 , PriceMask);
					for( k = 0 ; k < PriceMask ; ++k){
						BufDif += byte[k] * Math.pow(256 , k);
					}
					if(BufDif & pNegMask[1]){
						BufDif |= pRecovMask[PriceMask]; 
					}
					result[i].Price = result[i - 1].Price + BufDif / Times;
				}
			}
			
			var countVol:int = result[0]['Vol'];
			if(VolMask >= 4){
				for(i = 1 ; i < Count ; ++i){
					result[i]['Vol'] =  Math.round(pData.readFloat()*100)/100 - countVol ;
					countVol += result[i]['Vol'];
				}
			}
			else{
				for(i = 1 ; i < Count ; ++i){
					BufDif = 0;
					pData.readBytes( byte , 0 , VolMask);
					for( k = 0 ; k < VolMask ; ++k){
						BufDif += byte[k] * Math.pow(256 , k);
					}
					if(BufDif & pNegMask[2]){
						BufDif |= pRecovMask[VolMask]; 
					}
					result[i]['Vol'] =  BufDif;
				}
			}
			
			if(AmountMask >= 4){
				for(i = 1 ; i < Count ; ++i){
					result[i]['Amount'] = pData.readFloat();
				}
			}
			else{
				for(i = 1 ; i < Count ; ++i){
					BufDif = 0;
					pData.readBytes( byte , 0 , AmountMask);
					for( k = 0 ; k < AmountMask ; ++k){
						BufDif += byte[k] * Math.pow(256 , k);
					}
					if(BufDif & pNegMask[3]){
						BufDif |= pRecovMask[AmountMask];
					}
					result[i]['Amount'] = BufDif;

				}
			}
			
			return result;
			
		}
		
		
		/*
		enum E_MoBlockType{
		mbtSHIndex		= 0,    //上证指数
		mbtSHA			= 1,    //上海Ａ股
		mbtSHB			= 2,    //上海Ｂ股
		mbtSHFund		= 3,	//上海基金
		mbtSHBond		= 4,	//上海债券
		mbtSHWarrant	= 5,	//上海权证
		mbtSHOther		= 6,    //上海其他
		
		mbtSZIndex		= 7,    //深圳指数
		mbtSZA			= 8,    //深圳Ａ股
		mbtSZB			= 9,    //深圳Ｂ股
		mbtSZFund		= 10,	//深圳基金
		mbtSZBond		= 11,	//深圳债券
		mbtSZWarrant	= 12,	//深圳权证
		mbtSZOther		= 13,   //深圳其他
		
		mbtOtherBlock	= 14,	//其他板块
		
		mbtIndustry	= 15,	//行业板块
		mbtConcept		= 16,
		mbtArea		= 17,
		
		mbtFutures		= 18,
		mbtGEM			= 19,
		mbtMidSmall	= 20,
		
		mbtBlockEnd,
		};
		*/
		
		private function GetBlockType(Code:int):int{
			if(Code >= 600000 && Code <= 699999){
				return 1;
			}
			else if(Code >= 900000 && Code <= 900999){
				return 2;
			}
			else if(Code >= 1000000 && Code <= 1009999 || Code >= 1300000 && Code <= 1300999){
				return 8;
			}
			else if(Code >= 1200000 && Code <= 1209999){
				return 9;
			}
			else if(Code == 0 || Code == 800800 || Code == 800998 || Code == 800999 || Code == 801800 || (Code >= 0 && Code <= 999)){
				return 0;
			}
			else if(Code >= 1390000 && Code <= 1399999){
				return 7;
			}
			else if(Code >= 500000 && Code <= 529999){
				return 3;
			}
			else if(Code >= 580000 && Code <= 589999){
				return 5;
			}
			else if(Code >= 9000 && Code <= 29999 || Code >= 100000 && Code <= 199999){
				return 5;
			}
			else if(Code >= 1150000 && Code <= 1189999){
				return 10;
			}
			else if(Code >= 1030000 && Code <= 1039999){
				return 12;
			}
			else if(Code >= 1100000 && Code <= 1139999 || Code >= 1360000 && Code <= 1369999){
				return 12;
			}
			else if(Code >= 800801 && Code <= 800999){
				return 15;
			}
			else if(Code > 999999){
				return 6;
			}
			else{
				return 13;
			}
		}
	}
}