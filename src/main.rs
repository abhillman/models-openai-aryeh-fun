#[macro_use]
extern crate rocket;

use async_openai::{Client, Models};
use maud::{html, PreEscaped};
use serde_json::Value;
use table_to_html::HtmlTable;
use tabled::builder::Builder;

#[get("/")]
async fn index() -> Result<PreEscaped<String>, ()> {
    let client = Client::new();
    match Models::new(&client).list().await {
        Ok(models) => {
            let mut builder = Builder::default();
            let mut header_set = false;

            for model in models.data {
                let model_json = serde_json::to_value(model).unwrap();
                match model_json {
                    Value::Object(obj) => {
                        if !header_set {
                            builder.push_record(obj.keys());
                            header_set = true;
                        }

                        let mut values = vec![];
                        for value in obj.values() {
                            values.push(value.to_string());
                        }

                        builder.push_record(values);
                    }
                    _ => {
                        panic!("developer error.")
                    }
                }
            }

            let mut html_table = HtmlTable::with_header(Vec::<Vec<String>>::from(builder));
            html_table.set_border(1);

            let html = html! {
                head {
                    title {
                        "models.openai.aryeh.fun"
                    }
                }
                body {
                    pre {
                        (PreEscaped(html_table.to_string()))
                    }

                    div style="font-family: monospace" {
                        "built by " a href="https://www.linkedin.com/in/aryeh-hillman/" { "aryeh hillman" }"."
                    }
                }
            };

            Ok(html)
        }
        Err(e) => {
            eprintln!("Error: {:#?}", e);
            Err(())
        }
    }
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![index])
}
