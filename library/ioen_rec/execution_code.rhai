/// Subject: IOEN Renewable Energy Certificate (REC)
/// 
/// Inputs:
/// spender: [{logs, allocation}]
///   - logs: data blobs that contain the logs of the IOEN REC
///   - allocation: the allocated spends in the spend links to be cross-checked
/// 
/// Summary:
/// This is a simple return of the unyt_allocation


let unyt_allocation = [];
// sum up the values
let total_rec_amount = "0";
for s in spender {
  let logs = s.logs;
  let allocation = s.allocation;
 
  let log_value = get_data_blob(log);
  // Expected log format:
  // [
  //  {
  //    "source": "GRG - Bottling Plant - 1 Jan 2023 - 30 Nov 2024 - Raw Data",
  //    "project": "TBV-R1",
  //    "site": "GRG1-1",
  //    "owner_address": "uhCA...",
  //    "data": [
  //       { date: "2024-12", value: "0.00" }
  //       { date: "2024-11", value: "91.62" }
  //       ...
  //     ]
  //  }
  // ]

  for l in log_value {
    let total = "0";
    for data in l.data {
      total = add_fuel(total, data.value);
    }
    unyt_allocation.push(#{
      "receiver": l.owner_address,
      "amount": total,
      "proof": allocated.proof
    });
    total_rec_amount = add_fuel(total_rec_amount, total);
  }
}

return #{
  "unyt_allocation": unyt_allocation,
  "computed_values": #{
    "total_rec_amount": total_rec_amount
  }
}