module ATM_Controller_Testbench;
  reg clk;
  reg reset;
  reg card_inserted;
  reg pin_entered;
  reg transaction_selected;
  reg transaction_processed;
  reg card_ejected;
  reg withdrawal_requested;
  reg deposit_requested;
  reg balance_requested;
  wire card_eject;
  wire [3:0] transaction;
  wire withdrawal_completed;
  wire deposit_completed;
  wire [15:0] old_balance;
  wire [15:0] new_balance;
  wire [15:0] mini_statement;

  // Instantiate the module
  ATM_Controller dut (
    .clk(clk),
    .reset(reset),
    .card_inserted(card_inserted),
    .pin_entered(pin_entered),
    .transaction_selected(transaction_selected),
    .transaction_processed(transaction_processed),
    .card_ejected(card_ejected),
    .withdrawal_requested(withdrawal_requested),
    .deposit_requested(deposit_requested),
    .balance_requested(balance_requested),
    .card_eject(card_eject),
    .transaction(transaction),
    .withdrawal_completed(withdrawal_completed),
    .deposit_completed(deposit_completed),
    .old_balance(old_balance),
    .new_balance(new_balance),
    .mini_statement(mini_statement)
  );

  // Clock generation
  always begin
    #5 clk = ~clk;
  end

  // Initialize signals
  initial begin
    clk = 0;
    reset = 1;
    card_inserted = 0;
    pin_entered = 0;
    transaction_selected = 0;
    transaction_processed = 0;
    card_ejected = 0;
    withdrawal_requested = 0;
    deposit_requested = 0;
    balance_requested = 0;

    // Wait for some time
    #10 reset = 0;

    // Scenario 1: Successful withdrawal transaction
    card_inserted = 1;
    pin_entered = 1;
    transaction_selected = 1;
    withdrawal_requested = 1;
    #20 transaction_processed = 1;
    card_ejected = 1;
    #10 card_ejected = 0;
    card_inserted = 0;
    pin_entered = 0;
    transaction_selected = 0;
    withdrawal_requested = 0;
    transaction_processed = 0;

    // Scenario 2: Invalid PIN attempt
    card_inserted = 1;
    pin_entered = 1;
    withdrawal_requested = 1;
    pin_entered = 0;
    #5 pin_entered = 1;
    withdrawal_requested = 0;
    pin_entered = 1;
    #5 pin_entered = 0;
    withdrawal_requested = 1;
    pin_entered = 0;
    #5 pin_entered = 1;
    withdrawal_requested = 0;
    pin_entered = 1;
    #20 pin_entered = 0;
    card_inserted = 0;

    // Scenario 3: Balance inquiry transaction
    card_inserted = 1;
    pin_entered = 1;
    balance_requested = 1;
    #20 transaction_processed = 1;
    card_ejected = 1;
    #10 card_ejected = 0;
    card_inserted = 0;
    pin_entered = 0;
    balance_requested = 0;
    transaction_processed = 0;

    // Add more test scenarios as needed

    // Finish simulation
    #10 $finish;
  end

endmodule
