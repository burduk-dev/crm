FROM frappe/bench:latest

USER frappe
WORKDIR /home/frappe

COPY --chown=frappe:frappe render/frappe/start.sh /home/frappe/start.sh
RUN chmod +x /home/frappe/start.sh

EXPOSE 8000
CMD ["/home/frappe/start.sh"]
