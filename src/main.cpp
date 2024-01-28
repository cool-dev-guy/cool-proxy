#include "crow_all.h"
#include <cpr/cpr.h>

int main() {
    cpr::Session session;
    session.SetAcceptEncoding({{cpr::AcceptEncodingMethods::deflate, cpr::AcceptEncodingMethods::gzip, cpr::AcceptEncodingMethods::zlib}});
    
    crow::SimpleApp app;

    CROW_ROUTE(app, "/proxy/<path>")
        ([&session](std::string path) {
            session.SetUrl(cpr::Url{path});
            cpr::Response response = session.Get();
            return response.text;
        });

    CROW_ROUTE(app, "/m3u8/<path>")
        ([](std::string path) {
            auto page = crow::mustache::load("index.html");
            crow::mustache::context ctx({{"person", path}});
            return page.render(ctx);
        });

    CROW_ROUTE(app, "/")([]() {
        auto page = crow::mustache::load("index.html");
        return page.render();
    });

    CROW_ROUTE(app, "/<path>")
        ([](std::string path) {
            auto page = crow::mustache::load("index.html");
            crow::mustache::context ctx({{"page", path}});
            return page.render(ctx);
        });

    app.port(18080).multithreaded().run();
}
