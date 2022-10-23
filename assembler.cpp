/*
	Arkanil
*/
#include <bits/stdc++.h>
using namespace std;

#define fr(i, a, b) for (int i = a; i < b; i++)

typedef struct
{
    int location = -1;
    vector<int> call;

} jai;

map<string, int> mp;

map<string, jai> sp;

int pc = 0;

void index_keyword()
{

    mp["add"] = 1;
    mp["sub"] = 2;
    mp["mul"] = 3;
    mp["div"] = 4;
    mp["and"] = 5;
    mp["or"] = 6;
    mp["nand"] = 7;

    mp["nor"] = 8;
    mp["xor"] = 9;
    mp["slt"] = 10;
    mp["sgt"] = 11;
    mp["sll"] = 12;
    mp["srl"] = 13;
    mp["sla"] = 14;
    mp["sra"] = 15;
    mp["beq"] = 4;
    mp["bne"] = 5;
    mp["bgt"] = 6;
    mp["blt"] = 7;
    mp["j"] = 2;
    mp["jr"] = 3;
    mp["lw"] = 0;
    mp["sw"] = 1;
    mp["mfhi"] = 8;
    mp["mflo"] = 8;
    mp["mthi"] = 9;
    mp["mtlo"] = 9;

    return;
}
string dec_to_bin(int dec, int size)
{
    string t = "";
    while (size--)
    {
        if (dec & 1)
        {
            t += '1';
        }
        else
        {
            t += '0';
        }
        dec = dec >> 1;
    }
    reverse(t.begin(), t.end());

    return t;
}

string solve(string &t)
{
    vector<string> v;
    string ans = "";

    // string temp = "";

    // while (1)
    // {
    //     cin >> temp;
    //     if (temp[temp.size() - 1] == ';' || temp[temp.size() - 1] == ':')
    //     {
    //         t += temp;
    //         break;
    //     }
    //     else
    //     {
    //         t += temp;
    //         t += " ";
    //     }
    // }

    int size = t.size();
    // cout << t << endl;
    if (t[0] == ':')
    {
        // cout << pc << endl;

        jai it;
        it.location = pc + 1;
        if (sp.find(t.substr(1, size - 2)) != sp.end())
        {
            sp[t.substr(1, size - 2)].location = pc + 1;
        }
        else
            sp.insert({t.substr(1, size - 2), it});

        return "::";
    }

    string check = "";

    int lastind = 0;

    while (t[lastind] != ' ')
    {
        // cout << "hi" << endl;
        check += t[lastind];
        lastind++;
    }

    // cout << lastind << endl;
    int cnt_comma = 0, first_doll = 0, first_comma = 0, second_doll = 0, second_comma = 0;
    int brac = 0;

    fr(i, lastind, size)
    {
        if (t[i] == ',')
        {
            cnt_comma++;
            if (first_comma == 0)
                first_comma = i;
            else if (second_comma == 0)
            {
                second_comma = i;
            }
        }
        if (t[i] == '$')
        {

            if (first_doll == 0)
                first_doll = i;
            else
                second_doll == i;
        }
        if (t[i] == '(' && brac == 0)
        {
            brac = i;
        }
    }

    if (t[lastind - 1] == 'i' && check != "mfhi" && check != "mthi")
    {
        // cout << check << endl;
        int c_size = check.size();
        int d = 0, s = 0, imm = 0;
        if (cnt_comma == 1)
        {

            s = stoi(t.substr(first_doll + 1, first_comma - (first_doll + 1)));

            imm = stoi(t.substr(first_comma + 2, size - (first_comma + 2) - 1));

            ans += dec_to_bin(mp[check.substr(0, c_size - 1)] + 16, 6);
            // cout << ans << endl;
            ans += dec_to_bin(s, 5);
            // cout << ans << endl;
            ans += dec_to_bin(s, 5);
            // cout << ans << endl;
            ans += dec_to_bin(imm, 16);
            // cout << ans << endl;
            pc++;
            v.push_back(ans);
        }
        else if (cnt_comma == 2)
        {

            d = stoi(t.substr(first_doll + 1, first_comma - (first_doll + 1)));
            // cout<<d<<endl;
            s = stoi(t.substr(first_comma + 3, second_comma - (first_comma + 3)));
            // cout<<s<<endl;
            // cout<<second_comma + 2<<" "<<size - (second_comma + 2) - 1<<endl;
            imm = stoi(t.substr(second_comma + 2, size - (second_comma + 2) - 1));
            // cout<<imm<<endl;
            ans += dec_to_bin(mp[check.substr(0, c_size - 1)] + 16, 6);
            // cout << ans << endl;
            ans += dec_to_bin(s, 5);
            // cout << ans << endl;
            ans += dec_to_bin(d, 5);
            // cout << ans << endl;
            ans += dec_to_bin(imm, 16);
            // cout << ans << endl;
            pc++;
            v.push_back(ans);
        }
    }
    else
    {
        string label = "";
        if (cnt_comma == 2)
        {

            label = t.substr(second_comma + 2, size - (second_comma + 2) - 1);
        }
        if (check == "j")
        {
            // cout << check << "hi" << endl;
            label = t.substr(lastind + 1, size - 1 - (lastind + 1));
        }

        int s = 0, ti = 0, d = 0;

        if (check == "bne" || check == "bgt" || check == "beq" || check == "j" || check == "blt")
        {
            // cout<<"hi"<<endl;
            //  cout<<first_doll + 1<<" "<< first_comma - (first_doll + 1)<<endl;
            if (check != "j")
                s = stoi(t.substr(first_doll + 1, first_comma - (first_doll + 1)));
            // cout<<d<<endl;
            // cout<<first_comma + 3<<" "<<second_comma - (first_comma + 3)<<endl;
            if (check != "j")
                ti = stoi(t.substr(first_comma + 3, second_comma - (first_comma + 3)));
            // cout<<s<<endl;
            // cout<<second_comma + 2<<" "<<size - (second_comma + 2) - 1<<endl;

            // cout<<imm<<endl;

            ans += dec_to_bin(mp[check], 6);
            // cout << ans << endl;
            if (check != "j")
                ans += dec_to_bin(s, 5);

            // cout << ans << endl;

            if (check != "j")
            {
                ans += dec_to_bin(ti, 5);
            }

            pc++;

            // cout << check << endl;
            jai it;
            it.call.push_back(pc);
            if (sp.find(label) != sp.end())
            {

                sp[label].call.push_back(pc);
            }
            else
            {
                sp.insert({label, it});
            }

            v.push_back(ans);
        }
        else if (check == "jr")
        {
            ti = stoi(t.substr(first_doll + 1, size - (first_doll + 1) - 1));
            ans += dec_to_bin(mp[check], 6);
            // cout << ans << endl;
            ans += dec_to_bin(0, 5);
            // cout << ans << endl;
            ans += dec_to_bin(ti, 5);
            // cout << ans << endl;
            ans += dec_to_bin(0, 15);
            // cout << ans << endl;

            pc++;
            v.push_back(ans);
        }
        else if (check == "lw" || check == "sw")
        {
            int imm = 0;
            //  cout<< first_doll+1<<" "<<first_comma - (first_doll + 1)<<endl;
            d = stoi(t.substr(first_doll + 1, first_comma - (first_doll + 1)));
            // cout<< first_comma + 2<<" " <<brac - (first_comma + 2)<<endl;
            // cout<<d<<endl;
            imm = stoi(t.substr(first_comma + 2, brac - (first_comma + 2)));
            // cout<<brac+2<<" "<<size-(brac+2)-2<<endl;
            // cout<<imm<<endl;
            s = stoi(t.substr(brac + 2, size - (brac + 2) - 2));
            //    cout<<s<<endl;
            ans += dec_to_bin(mp[check], 6);
            // cout << ans << endl;
            ans += dec_to_bin(s, 5);
            // cout << ans << endl;
            ans += dec_to_bin(d, 5);
            // cout << ans << endl;
            ans += dec_to_bin(imm, 16);
            // cout << ans << endl;
            pc++;
            v.push_back(ans);
        }
        else if (check == "mfhi" || check == "mflo" || check == "mthi" || check == "mtlo")
        {

            if (check == "mfhi")
            {
                d = stoi(t.substr(first_doll + 1, size - 1 - (first_doll + 1)));
                ans += dec_to_bin(8, 6);
                // cout << ans << endl;
                ans += dec_to_bin(0, 5);
                // cout << ans << endl;
                ans += dec_to_bin(31, 5);
                // cout << ans << endl;
                ans += dec_to_bin(d, 5);
                // cout << ans << endl;
                ans += dec_to_bin(0, 5);
                // cout << ans << endl;
                ans += dec_to_bin(1, 6);
                // cout << ans << endl;
            }
            else if (check == "mflo")
            {
                d = stoi(t.substr(first_doll + 1, size - 1 - (first_doll + 1)));
                ans += dec_to_bin(8, 6);
                // cout << ans << endl;
                ans += dec_to_bin(0, 5);
                // cout << ans << endl;
                ans += dec_to_bin(30, 5);
                // cout << ans << endl;
                ans += dec_to_bin(d, 5);
                // cout << ans << endl;
                ans += dec_to_bin(0, 5);
                // cout << ans << endl;
                ans += dec_to_bin(1, 6);
                // cout << ans << endl;
            }
            else if (check == "mthi")
            {
                s = stoi(t.substr(first_doll + 1, size - 1 - (first_doll + 1)));
                ans += dec_to_bin(9, 6);
                // cout << ans << endl;
                ans += dec_to_bin(s, 5);
                // cout << ans << endl;
                ans += dec_to_bin(0, 5);
                // cout << ans << endl;
                ans += dec_to_bin(31, 5);
                // cout << ans << endl;
                ans += dec_to_bin(0, 5);
                // cout << ans << endl;
                ans += dec_to_bin(1, 6);
                // cout << ans << endl;
            }
            else if (check == "mtlo")
            {
                s = stoi(t.substr(first_doll + 1, size - 1 - (first_doll + 1)));
                ans += dec_to_bin(9, 6);
                // cout << ans << endl;
                ans += dec_to_bin(s, 5);
                // cout << ans << endl;
                ans += dec_to_bin(0, 5);
                // cout << ans << endl;
                ans += dec_to_bin(30, 5);
                // cout << ans << endl;
                ans += dec_to_bin(0, 5);
                // cout << ans << endl;
                ans += dec_to_bin(1, 6);
                // cout << ans << endl;
            }
            pc++;
            v.push_back(ans);
        }
        else
        {

            // int c_size = check.size();
            int d = 0, s = 0, ti = 0;
            if (cnt_comma == 1)
            {
                // cout << first_doll + 1 << " " << first_comma - (first_doll + 1) << endl;

                s = stoi(t.substr(first_doll + 1, first_comma - (first_doll + 1)));
                // cout<<s<<endl;
                //    cout<< first_comma + 2<<" "<<size - (first_comma + 2) - 1<<endl;
                ti = stoi(t.substr(first_comma + 3, size - (first_comma + 3) - 1));
                // cout<<ti<<endl;

                if (t[lastind - 1] != 'u')
                    ans += dec_to_bin(16, 6);
                else
                    ans += dec_to_bin(48, 6);
                // cout << ans << endl;
                ans += dec_to_bin(s, 5);
                // cout << ans << endl;
                ans += dec_to_bin(ti, 5);
                // cout << ans << endl;
                ans += dec_to_bin(s, 5);
                // cout << ans << endl;
                ans += dec_to_bin(0, 5);
                // cout << ans << endl;
                ans += dec_to_bin(mp[check], 6);
                // cout << ans << endl;

                pc++;
                v.push_back(ans);
            }
            else if (cnt_comma == 2)
            {

                d = stoi(t.substr(first_doll + 1, first_comma - (first_doll + 1)));
                // cout<<d<<endl;
                s = stoi(t.substr(first_comma + 3, second_comma - (first_comma + 3)));
                // cout<<s<<endl;
                // cout<<second_comma + 2<<" "<<size - (second_comma + 2) - 1<<endl;
                ti = stoi(t.substr(second_comma + 3, size - (second_comma + 3) - 1));
                // cout<<imm<<endl;
                if (t[lastind - 1] != 'u')
                    ans += dec_to_bin(16, 6);
                else
                    ans += dec_to_bin(48, 6);
                // cout << ans << endl;
                ans += dec_to_bin(s, 5);
                // cout << ans << endl;
                ans += dec_to_bin(ti, 5);
                // cout << ans << endl;
                ans += dec_to_bin(d, 5);
                // cout << ans << endl;
                ans += dec_to_bin(0, 5);
                // cout << ans << endl;
                ans += dec_to_bin(mp[check], 6);
                // cout << ans << endl;
                pc++;
                v.push_back(ans);
            }
        }
    }
    // cout << pc << endl;
    return ans;
}

vector<string> solver(vector<string> input_call)
{
    vector<string> v;
    v.push_back("11111110000000000000000000000000");
    index_keyword();
    string temp;
    int _last, last = input_call.size()-1, insert_no = 0;
    _last = last;
    while(1) {
        if (input_call[last][0]==':') {
            last--;
            _last--;
        }
        if (input_call[last][0]=='b'||input_call[last][0]=='j') {
            break;
        }
        else {
            last--;
        }
        if (last+1<_last) {
            break;
        }
    }

    for (int i=0; i<(2-(_last-last)); i++) {
        if (input_call[last][0]==':') {
            temp = input_call[last];
            input_call[last] = "addi $0, 0;";
            input_call.push_back(temp);
        }
        input_call.push_back("addi $0, 0;");
    }

    int input_size = input_call.size();
    
    fr(i, 0, input_size)
    {
        temp = solve(input_call[i]);

        if (temp != "::")
            v.push_back(temp);
    }

    for (auto it : sp)
    {
        if (it.second.call.size() != 0)
        {
            int size = it.second.call.size();
            int loc = it.second.location;

            if (loc != -1)
            {
                for (int i = 0; i < size; i++)
                {
                    int num = loc - it.second.call[i] - 2;
                    // cout << loc << " " << it.second.call[i] << endl;
                    string ch = v[it.second.call[i]].substr(0, 4);
                    if (ch != "0000")
                    {
                        v[it.second.call[i]] += dec_to_bin(num, 16);
                    }
                    else
                    {
                        v[it.second.call[i]] += dec_to_bin(num, 26);
                    }
                }
            }
        }
    }
    v.push_back("11111100000000000000000000000000");
    return v;
}
// Manisha
string trim(string temp)
{
  int s = 0;
  int e = temp.size();
  bool found = false;
  while (1 && s < temp.size())
  {
    if (temp.at(s) >= 'a' && temp.at(s) <= 'z' || temp.at(s) == ':')
      break;
    s++;
  }
  while (1 && e > 0)
  {
    if (temp.at(e - 1) == ';' || temp.at(e - 1) == ':')
      break;
    e--;
  }
  string t = ((e - s > 0)) ? temp.substr(s, e - s) : "";
  return t;
}
    
int main()
{   // Manisha
    string line;
    string temp = "";
    ifstream myfile("testcase.txt");
    vector<string> instructions, output_vec;
    if (myfile.is_open())
    {   
        while (getline(myfile, line))
        {
            // cout << "*" << line << "*" << '\n';
            temp = trim(line);
            // cout << "*" << temp << "*" << endl;
            if (temp.size() > 0)
                instructions.push_back(line);
        }
        myfile.close();
    }
    else
        cout << "Unable to open file";

    output_vec = solver(instructions);
    // cout<<"hi"<<endl;
    int size = output_vec.size();
    fr(i, 0, size)
    {
        cout << output_vec[i] << endl;
    }

    return 0;
}
