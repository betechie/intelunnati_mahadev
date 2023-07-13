module ATM_Controller (
  input wire clk,
  input wire reset,
  input wire card_inserted,
  input wire pin_entered,
  input wire transaction_selected,
  input wire transaction_processed,
  input wire card_ejected,
  input wire withdrawal_requested,
  input wire deposit_requested,
  input wire balance_requested,
  output reg card_eject,
  output reg [3:0] transaction,
  output reg withdrawal_completed,
  output reg deposit_completed,
  output reg [15:0] old_balance,
  output reg [15:0] new_balance,
  output reg [15:0] mini_statement
);

  // Define the states
  localparam IDLE_STATE = 4'b0000;
  localparam CARD_INSERTED_STATE = 4'b0001;
  localparam PIN_VERIFIED_STATE = 4'b0010;
  localparam PIN_INVALID_STATE = 4'b0011;
  localparam LOCKED_STATE = 4'b0100;
  localparam TRANSACTION_SELECTED_STATE = 4'b0101;
  localparam WITHDRAWAL_STATE = 4'b0110;
  localparam DEPOSIT_STATE = 4'b0111;
  localparam BALANCE_INQUIRY_STATE = 4'b1000;
  localparam TRANSACTION_COMPLETE_STATE = 4'b1001;

  // Define the parameters
  localparam MAX_PIN_ATTEMPTS = 3;
  localparam LOCKED_DURATION = 24;

  // Define the outputs
  reg [3:0] state;
  reg [2:0] pin_attempts;
  reg [3:0] lock_timer;
  reg [15:0] balance;

  // Define the state register
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE_STATE;
      pin_attempts <= 0;
      lock_timer <= 0;
    end
    else begin
      case (state)
        IDLE_STATE:
          if (card_inserted)
            state <= CARD_INSERTED_STATE;
          else if (card_ejected)
            state <= IDLE_STATE;
        CARD_INSERTED_STATE:
          if (pin_entered && pin_attempts < MAX_PIN_ATTEMPTS) begin
            if (pin_entered == 4'b0000) // Replace with actual valid PIN
              state <= PIN_VERIFIED_STATE;
            else begin
              pin_attempts <= pin_attempts + 1;
              if (pin_attempts == MAX_PIN_ATTEMPTS)
                state <= LOCKED_STATE;
              else
                state <= PIN_INVALID_STATE;
            end
          end
          else if (card_ejected)
            state <= IDLE_STATE;
        PIN_VERIFIED_STATE:
          if (transaction_selected)
            state <= TRANSACTION_SELECTED_STATE;
          else if (card_ejected)
            state <= IDLE_STATE;
        PIN_INVALID_STATE:
          if (pin_entered) begin
            pin_attempts <= pin_attempts + 1;
            if (pin_attempts == MAX_PIN_ATTEMPTS)
              state <= LOCKED_STATE;
            else
              state <= CARD_INSERTED_STATE;
          end
          else if (card_ejected)
            state <= IDLE_STATE;
        LOCKED_STATE:
          if (lock_timer == LOCKED_DURATION)
            state <= IDLE_STATE;
          else
            lock_timer <= lock_timer + 1;
        TRANSACTION_SELECTED_STATE:
          if (transaction_processed)
            state <= TRANSACTION_COMPLETE_STATE;
          else if (card_ejected)
            state <= IDLE_STATE;
        WITHDRAWAL_STATE, DEPOSIT_STATE, BALANCE_INQUIRY_STATE, TRANSACTION_COMPLETE_STATE:
          if (card_ejected)
            state <= IDLE_STATE;
        default:
          state <= IDLE_STATE;
      endcase
    end
  end

  // Define the output register assignments
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      card_eject <= 0;
      transaction <= 0;
      withdrawal_completed <= 0;
      deposit_completed <= 0;
      old_balance <= 0;
      new_balance <= 0;
      mini_statement <= 0;
      balance <= 1000; // Replace with initial balance value
    end
    else begin
      card_eject <= (state == WITHDRAWAL_STATE || state == DEPOSIT_STATE || state == TRANSACTION_COMPLETE_STATE) ? 1'b1 : 1'b0;
      transaction <= transaction_selected ? transaction : 4'b0000;
      withdrawal_completed <= (state == WITHDRAWAL_STATE && transaction_processed) ? 1'b1 : 1'b0;
      deposit_completed <= (state == DEPOSIT_STATE && transaction_processed) ? 1'b1 : 1'b0;
      mini_statement <= (state == BALANCE_INQUIRY_STATE && transaction_processed) ? 1'b1 : 1'b0;

      case (state)
        PIN_VERIFIED_STATE:
          begin
            old_balance <= balance;
            if (transaction_selected == 4'b0001) begin // Replace with withdrawal transaction code
              new_balance <= balance - transaction;
              balance <= new_balance;
            end
            else if (transaction_selected == 4'b0010) begin // Replace with deposit transaction code
              new_balance <= balance + transaction;
              balance <= new_balance;
            end
            else
              new_balance <= balance;
          end
        BALANCE_INQUIRY_STATE:
          begin
            old_balance <= balance;
            new_balance <= balance;
          end
        default:
          begin
            old_balance <= 0;
            new_balance <= 0;
          end
      endcase
    end
  end

endmodule
