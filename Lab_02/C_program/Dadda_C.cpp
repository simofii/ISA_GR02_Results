#include<vector>
#include <iostream>
#include<fstream>
#include<string>
#include <bitset>
#include<time.h>
#define BIT_INPUT 32

using namespace std;

struct Signal
{
	char sig_code='0';	//used in the table 0=not used, X=input, C=carry out of an adder, S=num bit output of an adder
	short item_num = -1;	//itedtifies the signal inside the vector: either the partial result bit number (0=LSB of the partial result), or #number
					//of the adder instanciated in the previous stage. -1=unused signal
	short stage = -1;	//If this is not an input, it indicates the number of the stage in which is instantiated the adder that
						//this signal is the result or carry bit of
						//If this is un input it indicates the encoder number that calculated this partial product
	bool used = false;

	bool bit = false;
};

bitset<64> find_adder(vector<vector<Signal>>& tab, const int* stages, const int& prev_stage_number, ofstream& file_report, ofstream& vhdl_portmap, ofstream& vhdl_signal);

int cnt_data_col(const vector<vector<Signal>>& tab, const int& col, const int& num_row);

void print_tab(const vector<vector<Signal>>& tab, ostream &stream);

string sig_name(const Signal& sig);

void code_adder(const bool& full, const int& adder_stage, const int& num_adder, ofstream& vhdl_portmap, const Signal *sig);

void fa(const Signal* inputs, bool *result);

void ha(const Signal* inputs, bool* result);

void partial_product(const long long& in1, const long long& in2, const int& n_bit, vector<bitset<BIT_INPUT + 5>>& pp_tab);

void clear_used_in_tab(vector<vector<Signal>>& tab);


int main()
{
	const int NUM_ROW = 17;
	const int NUM_COL = BIT_INPUT * 2;
	vector<vector<Signal>> tab;
	//tab[riga][colonna]
	int stages[7] = {13, 9, 6, 4, 3, 2, 1};

	ofstream file_report;
	file_report.open("report_tab.txt");

	ofstream vhdl_portmap;		//file in cui scrivo il codice vhdl, esclusivamente dei portmap
	vhdl_portmap.open("vhdl_portmap.txt");

	ofstream vhdl_signal;		//file in cui scrivo il codice vhdl che instanzia i segnali utilizzati per l'implementazione del dadda tree
	vhdl_signal.open("vhdl_signal.txt");

	ifstream file_in;			//file di report utilizzato per debuggare
	file_in.open("../data_dadda.txt");
	if (!file_in.is_open())
		throw;

	srand(time(NULL));

	for (int j = 0; j < NUM_ROW; j++)	//leggo file di ingresso e popolo la tabella dei segnali
	{
		vector<Signal> tmp_vector;
		Signal tmp_signal;
		bool next_blank = false;
		short input_number = -1;
		
		for (int i = 0; i < NUM_COL; i++)	//leggo riga file e divido i dati il numero giusto di volta, il file è ipotizzato corretto
		{
			
			if (char(file_in.get()) == '0') {	//leggo '0'
				tmp_signal.sig_code = '0';
				if (next_blank == true){	//caso tra partial product ed s
					tmp_signal.item_num = input_number;
					next_blank = false;
					input_number--;
					tmp_signal.stage = j;
				}
				else {	// caso standard
					tmp_signal.item_num = -1;
				}
			}
			else    //ho letto un dato valido
			{
				if (input_number == -1)
					next_blank = true;

				if (input_number == -1)	//assegno numero di bit da leggere dal file in base alla riga in cui mi trovo
				{
					if (j == 0 || j == 15)
						input_number = 35;
					else if (j == 16)
						input_number = 33;
					else
						input_number = 36;
				}

				//preparo oggetto di tipo Signal per essere inserito nella tabella
				tmp_signal.sig_code = 'X';
				tmp_signal.item_num = input_number;
				tmp_signal.stage = j;
				input_number--;
			}

			//inserisco dato appena letto in tabella
			tmp_vector.insert(tmp_vector.begin(), tmp_signal);
				
		}
		file_in.get();
		tab.push_back(tmp_vector);
	}




	//Calcolo prodotti parziali
	for (int i = 0; i < 10000; i++)
	{
		unsigned int in1 = (rand() << (rand() %30)), in2 = (rand() << (rand() %30));
		vector<bitset< BIT_INPUT + 5>> pp_tab;
		partial_product(in1, in2, BIT_INPUT, pp_tab);

		//Inserisco dati dei prodotti parziali in tabella
		for (int i = 0; i < NUM_COL; i++)
		{
			for (int j = 0; j < NUM_ROW; j++)
			{
				if (tab[j][i].item_num != -1)
				{
					tab[j][i].bit = pp_tab[j][tab[j][i].item_num];
				}
			}
		}

		//resetto valori della tabella per poter eseguire nuovamente l'algoritmo
		clear_used_in_tab(tab);

		//Algoritomo DADDA TREE
		bitset<64> result;
		result = find_adder(tab, stages, NUM_ROW, file_report, vhdl_portmap, vhdl_signal);

		//controllo risultati alla ricerca di errori
		if (((long long)in1 * (long long)in2) != result.to_ullong())
		{
			cout << "Error!" << endl;
			cout << "in1 = " << in1 << "; in2 = " << in2 << endl;
		}
		else
			cout << "OK!" << endl;

		//output risultato moltiplicazione
		cout << result.to_string() << endl;
		cout << hex << result.to_ullong() << endl << endl;

		vhdl_portmap.close();
		vhdl_signal.close();
	}

	//vector<bitset< BIT_INPUT + 5>> pp_tab;
	//partial_product(0x0, 0x3e9e377a, BIT_INPUT, pp_tab);

	////Inserisco dati dei prodotti parziali in tabella
	//for (int i = 0; i < NUM_COL; i++)
	//{
	//	for (int j = 0; j < NUM_ROW; j++)
	//	{
	//		if (tab[j][i].item_num != -1)
	//		{
	//			tab[j][i].bit = pp_tab[j][tab[j][i].item_num];
	//		}
	//	}
	//}

	//for (int j = 0; j < NUM_ROW; j++)
	//{
	//	for (int i = NUM_COL - 1; i >= 0; i--)
	//	{
	//		file_report << (int)tab[j][i].bit;
	//	}
	//	file_report << endl;
	//}


	////Algoritomo DADDA TREE
	//bitset<64> result;
	//result = find_adder(tab, stages, NUM_ROW, file_report, vhdl_portmap, vhdl_signal);

	//cout << result.to_string() << endl;
	//cout << hex << result.to_ullong() << endl;

	file_report.close();
	vhdl_portmap.close();
	vhdl_signal.close();
	return 0;
}


bitset<64> find_adder(vector<vector<Signal>>& tab, const int* stages, const int& prev_stage_number, ofstream &file_report, ofstream& vhdl_portmap, ofstream& vhdl_signal)
{
	int i, stage_target;
	for (i = 0; stages[i] >= prev_stage_number; i++);
	stage_target = stages[i];
	int adder_stage = i + 1;	//numero dello stage
	int num_adder_in_stage = 0;	//numero di adder instazioati in questo stage

	vector<vector<Signal>> tab_new;

	long long result;

	//allocate a new smaller tab, used to compute the adder location

	if (stage_target == 1)	//ultima esecuzione della funzione, devo allocare un ripple carry adder
	{
		bool first = true;
		Signal tmp;
		tmp.sig_code = 'C';
		tmp.stage = adder_stage;
		for (int j = 0; j < (int)tab[0].size(); j++)
		{
			tmp.item_num = j;
			if (vhdl_portmap.is_open())			//se il file di output è disponibile, scrivo il codice vhdl del ripple carry adder
			{
				vhdl_portmap << endl << endl << "add_num" << num_adder_in_stage << "_st" << adder_stage << " : ";
				if (first == true)
					vhdl_portmap << "ha ";
				else
					vhdl_portmap << "fa ";
				vhdl_portmap << "port map (in1 => ";
				vhdl_portmap << sig_name(tab[0][j]);
				vhdl_portmap << ", in2 => ";
				vhdl_portmap << sig_name(tab[1][j]);
				if (first == false)
				{
					tmp.item_num--;
					vhdl_portmap << ", c_in => ";
					vhdl_portmap << sig_name(tmp);
					tmp.item_num++;
				}
				vhdl_portmap << ", sum => ";
				vhdl_portmap << "result(" << j << ")";
				vhdl_portmap << ", c_out => ";
				if (j == tab[0].size() - 1)
					vhdl_portmap << "result(" << j + 1;
				else
					vhdl_portmap << sig_name(tmp);
				vhdl_portmap << ");";
			}
			first = false;
			num_adder_in_stage++;
		}

		if (vhdl_signal.is_open())		//se il file di output è disponibile, istanzion i segnali utilizzati per l'implementazione del ripple carry adder
		{
			vhdl_signal << endl << "signal carry_st" << adder_stage << " : std_logic_vector(" << num_adder_in_stage - 1 << " downto 0);";
			vhdl_signal << endl << "signal result : std_logic_vector(" << num_adder_in_stage << " downto 0);";
		}

		bitset<64> num1, num2;
		for (int z = 0; z < (int)tab[0].size() - 1; z++)		//salvo risultato ed ingoro i due MSB
		{
			num1[z] = tab[0][z].bit;
			num2[z] = tab[1][z].bit;
		}
			
		result = num1.to_ullong() + num2.to_ullong();

	}
	else   //non sono nel caso in cui devo istanziare il ripple carry, eseguo un iterazione dell'algoritmo per la creazione DADDA tree
	{

		//creo nuova tabella per i risultati dello stage
		for (int i = 0; i < stage_target; i++)
		{
			vector<Signal> tmp_vector;
			Signal tmp;
			tmp.sig_code = '0';
			tmp.item_num = -1;
			for (int j = 0; j < (int)tab[0].size(); j++)
			{
				tmp_vector.push_back(tmp);
			}
			tab_new.push_back(tmp_vector);
		}

		for (int i = 0; i < (int)tab[0].size(); i++)	//ciclo tu tutte le colonne della tabella di dati
		{
			int num_data_old_stage, num_data_current_stage, num_data_tot;
			num_data_old_stage = cnt_data_col(tab, i, tab.size());
			num_data_current_stage = cnt_data_col(tab_new, i, tab_new.size());
			num_data_tot = num_data_current_stage + num_data_old_stage;

			if (num_data_tot <= stage_target) {		//non servono adder

				for (int j = 0; j < (int)tab.size(); j++)	//copio i dati rilevanti presenti nella tabella vecchia in quella nuova
				{
					if (tab[j][i].sig_code != '0')	//trovato dato significante
					{
						int k;
						for (k = 0; tab_new[k][i].sig_code != '0'; k++);	//trova spazio vuoto
						tab_new[k][i] = tab[j][i];
					}
				}
			}
			else	//devo istanziare adder
			{
				int num_fa, num_ha = 0;
				for (num_fa = 0; num_data_tot - (2 * num_fa) > stage_target; num_fa++);			//calcolo numero adder da istanziare in una determinata colonna

				if (i + 1 == tab_new[0].size())		//in caso di overflow in uno delgi stadi precedenti, estendo la tabella di una colonna
				{
					Signal tmp;
					for (int j = 0; j < (int)tab_new.size(); j++)
						tab_new[j].insert(tab_new[j].end(), tmp);
				}

				if (num_data_tot - (2 * num_fa) == stage_target - 1)	//controllo se posso sostituire un fa con un ha
				{
					num_fa--;
					num_ha++;
				}

				for (int j = 0; j < num_fa + num_ha; j++)	//ciclo che permette di istanziare gli adder
				{
					bool result[2];
					int num_adder_input;
					if (j < num_fa)
						num_adder_input = 3;
					else
						num_adder_input = 2;

					Signal input_adder[3];
					Signal output_adder[2];
					for (int k = 0; k < num_adder_input; k++)	//selezione dati ingresso adder
					{
						int z;
						for (z = 0; tab[z][i].sig_code == '0' || tab[z][i].used == true; z++);	//trova spazio vuoto
						tab[z][i].used = true;
						input_adder[k] = tab[z][i];
					}

					//calcolo risultati oer simulazione
					if (num_adder_input == 2)
						ha(input_adder, result);
					else
						fa(input_adder, result);

					//inserisco in tabella i risultati di un genrico adder (ha/fa)
					Signal tmp;
					//inserisco in tabella segnale di sum adder 
					int k;
					for (k = 0; tab_new[k][i].sig_code != '0'; k++);	//trova spazio vuoto
					tmp.sig_code = 'S';
					tmp.stage = adder_stage;
					tmp.item_num = num_adder_in_stage;
					tmp.bit = result[0];
					tab_new[k][i] = tmp;
					output_adder[0] = tmp;

					//inserisco in tabella segnale di carry adder 
					for (k = 0; tab_new[k][i + 1].sig_code != '0'; k++);	//trova spazio vuoto
					tmp.sig_code = 'C';
					tmp.stage = adder_stage;
					tmp.item_num = num_adder_in_stage;
					tmp.bit = result[1];
					tab_new[k][i + 1] = tmp;
					output_adder[1] = tmp;

					//scrivi vhdl sul file di output
					if (vhdl_portmap.is_open())
					{
						if (j < num_fa)
							code_adder(true, adder_stage, num_adder_in_stage, vhdl_portmap, input_adder);
						else
							code_adder(false, adder_stage, num_adder_in_stage, vhdl_portmap, input_adder);
					}

					num_adder_in_stage++;
				}

				//copio i restanti segnali in tab_new, cioè i segnali che non sono stati dati in ingtresso ad un adder
				for (int k = 0; k < (int)tab.size(); k++)
				{
					if (tab[k][i].sig_code != '0' && tab[k][i].used == false)
					{
						int z;
						for (z = 0; tab_new[z][i].sig_code != '0'; z++);	//trova spazio vuoto
						tab_new[z][i] = tab[k][i];
					}
				}
			}
		}

		//istanzio segnali per le uscite delgi adder di questo stage
		if (vhdl_signal.is_open())
		{
			vhdl_signal << endl << "signal sum_st" << adder_stage << " : std_logic_vector(" << num_adder_in_stage - 1 << " downto 0);";
			vhdl_signal << endl << "signal carry_st" << adder_stage << " : std_logic_vector(" << num_adder_in_stage - 1 << " downto 0);";
		}

		//salva risultati su file di report
		/*print_tab(tab, file_report);
		print_tab(tab_new, file_report);
		for (int z = 0; z < (int)tab_new[0].size(); z++)
		{
			for (int j = 0; j < (int)tab_new.size(); j++)
			{
				file_report << "row=" << j << " col=" << z << " " << tab_new[j][z].sig_code << " " << tab_new[j][z].item_num << " " << tab_new[j][z].stage << endl;
			}
		}*/
	}

	//ricorsione funzione
	if(stage_target != 1)
		result = (find_adder(tab_new, stages, stage_target, file_report, vhdl_portmap, vhdl_signal)).to_ullong();

	return bitset<64>(result);
}

int cnt_data_col(const vector<vector<Signal>>& tab, const int& col, const int& num_row)
{
	//returns the number of actual data (sig_code != '0') in a ceratin column
	int num_data = 0;
	for (int i = 0; i < num_row; i++)
	{
		if (tab[i][col].sig_code != '0')
			num_data++;
	}
	return num_data;
}

void print_tab(const vector<vector<Signal>>& tab, ostream& stream)
{
	//stampa su uno stream la tabella dei segnali, utile per il debug
	for (int i = 0; i < (int)tab.size(); i++)
	{
		stream << i << " ";
		if (i < 10)
			stream << " ";
		for (int j = (tab[0].size() - 1); j >= 0; j--)
		{
			stream << (char)tab[i][j].sig_code << " ";
		}
		stream << endl;
	}
	stream << endl << endl;
	return;
}

string sig_name(const Signal& sig)
{
	//dato un segnale preso dalla tabella, restituisce il suo nome utilizzato nel vhdl
	string name;
	if (sig.sig_code == '0')
		name = "'0'";
	else if (sig.sig_code == 'X')
	{
		name = "part_prod(" + to_string(sig.stage);
		name += ")(";
		name += to_string(sig.item_num);
		name += ")";
	}
	else if (sig.sig_code == 'S')
	{
		name = "sum_st" + to_string(sig.stage);
		name += "(";
		name += to_string(sig.item_num);
		name += ")";
	}
	else if (sig.sig_code == 'C')
	{
		name = "carry_st" + to_string(sig.stage);
		name += "(";
		name += to_string(sig.item_num);
		name += ")";
	}
		
	return name;
}

void code_adder(const bool& full, const int& adder_stage, const int& num_adder, ofstream& vhdl_portmap, const Signal* sig)
{

	//restituisce il codice vhdl necessario ad istanziare un adder
	Signal tmp;
	vhdl_portmap << endl << endl << "add_num" << num_adder << "_st" << adder_stage << " : ";
	if (full == true)
		vhdl_portmap << "fa ";
	else
		vhdl_portmap << "ha ";
	vhdl_portmap << "port map (in1 => ";
	vhdl_portmap << sig_name(sig[0]);
	vhdl_portmap << ", in2 => ";
	vhdl_portmap << sig_name(sig[1]);
	if (full == true)
	{
		vhdl_portmap << ", c_in => ";
		vhdl_portmap << sig_name(sig[2]);
	}
	vhdl_portmap << ", sum => ";
	tmp.sig_code = 'S';
	tmp.stage = adder_stage;
	tmp.item_num = num_adder;
	vhdl_portmap << sig_name(tmp);
	vhdl_portmap << ", c_out => ";
	tmp.sig_code = 'C';
	vhdl_portmap << sig_name(tmp);
	vhdl_portmap << ");";
}

void fa(const Signal* inputs, bool* result)
{
	//implementazione FULL ADDER
	const bool a=inputs[0].bit, b = inputs[1].bit, c_in = inputs[2].bit;
	int res = a + b + c_in;
	result[0] = res & 1;
	result[1] = res & (1 << 1);
	return;
}

void ha(const Signal* inputs, bool* result)
{
	//implementazione HALF ADDER
	const bool a = inputs[0].bit, b = inputs[1].bit;
	int res = a + b;
	result[0] = res & 1;
	result[1] = res & (1 << 1);
	return;
}

void partial_product(const long long& in1, const long long& in2, const int& n_bit, vector<bitset<BIT_INPUT + 5>>& pp_tab)
{
	int num_prod = (int)((n_bit + 2) / 2);
	bool first = true;
	bool s = false, s_old = false;
	const long long a = in1;
	bitset<BIT_INPUT+3> b(in2);
	b <<= 1;		//creo 0 iniziale

	for (int i = 0; i < num_prod; i++)
	{
		long long tmp_part_prod;
		bitset<3> input_encoder;
		input_encoder[2] = b[(2 * i) + 2];
		input_encoder[1] = b[(2 * i) + 1];
		input_encoder[0] = b[(2 * i)];

		s_old = s;

		if (input_encoder == bitset<3>("000") || input_encoder == bitset<3>("111"))
			tmp_part_prod = 0;
		else if (input_encoder == bitset<3>("011") || input_encoder == bitset<3>("100"))
			tmp_part_prod = ((long long)a << 1);
		else
			tmp_part_prod = a;

		//inverto segnale se necessario
		if (input_encoder == bitset<3>("100") || input_encoder == bitset<3>("101") || input_encoder == bitset<3>("110"))
		{
			tmp_part_prod ^= (((long long)1 << (n_bit + 1)) - 1);
			s = true;
		}
		else
			s = false;

		bitset<BIT_INPUT + 5> tmp;
		//calcolo prodotti parziali
		if (first)
		{
			tmp = ((long long)!s << (n_bit + 3)) + ((long long)s << (n_bit + 2)) + ((long long)s << (n_bit + 1)) + tmp_part_prod;
			first = false;
		}
		else
			tmp = ((long long)1 << (n_bit + 4)) + ((long long)(!s) << (n_bit + 3)) + (tmp_part_prod << 2) + s_old;

		
		pp_tab.push_back(tmp);



	}





}

void clear_used_in_tab(vector<vector<Signal>>& tab)
{
	for (int i = 0; i < (int)tab[0].size(); i++)
	{
		for (int j = 0; j < (int)tab.size(); j++)
		{
			tab[j][i].used = false;
		}
	}
}
