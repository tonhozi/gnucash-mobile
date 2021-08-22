import 'package:flutter/material.dart';
import 'package:ptofinance/providers/accounts.dart';
import 'package:ptofinance/providers/transactions.dart';
import 'package:ptofinance/widgets/transaction_form.dart';
import 'package:ptofinance/widgets/transactions_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import 'account_view.dart';

class ListOfAccounts extends StatelessWidget {
  final List<Account> accounts;

  ListOfAccounts({Key key, @required this.accounts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<TransactionsModel>(
          builder: (context, transactionsModel, child) {
        return ListView.builder(
          itemBuilder: (context, index) {
            if (index.isOdd) {
              return Divider();
            }

            final int i = index ~/ 2;
            if (i >= this.accounts.length) {
              return null;
            }

            final _account = this.accounts[i];
            final List<Transaction> _transactions = [];
            for (var key
                in transactionsModel.transactionsByAccountFullName.keys) {
              if (key.startsWith(_account.fullName)) {
                _transactions.addAll(
                    transactionsModel.transactionsByAccountFullName[key]);
              }
            }
            final double _balance = _transactions.fold(0.0,
                (previousValue, element) => previousValue + element.amount);

            return ListTile(
              title: Text(
                _account.name,
                style: Constants.biggerFont,
              ),
              trailing: Text(
                NumberFormat.simpleCurrency(decimalDigits: 2).format(_balance),
              ),
              onTap: () {
                if (_account.children.length == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return Scaffold(
                        appBar: AppBar(
                          title: Text(_account.fullName),
                        ),
                        body: TransactionsView(
                            transactions: Provider.of<TransactionsModel>(
                                            context,
                                            listen: true)
                                        .transactionsByAccountFullName[
                                    _account.fullName] ??
                                []),
                        floatingActionButton: Builder(builder: (context) {
                          return FloatingActionButton(
                            backgroundColor: Constants.darkBG,
                            child: Icon(Icons.add),
                            onPressed: () async {
                              final _success = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransactionForm(
                                    toAccount: _account,
                                  ),
                                ),
                              );

                              if (_success != null && _success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Transaction created!")));
                              }
                            },
                          );
                        }),
                      );
                    }),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountView(account: _account),
                    ),
                  );
                }
              },
            );
          },
          padding: EdgeInsets.all(16.0),
          shrinkWrap: true,
        );
      }),
    );
  }
}
