<template>
  <q-page class="flex flex-start">
    <order-table title="All Orders" :today="false" />
    <div>
      <q-dialog v-model="addOrder" persistent>
        <add-order-card />
      </q-dialog>
    </div>
    <q-page-sticky position="bottom-right" :offset="[18, 18]">
      <q-btn fab icon="add" color="red" @click="addOrder = true" />
    </q-page-sticky>
    <q-spinner
      color="primary"
      size="3em"
      :thickness="10"
      class="q-mt-md"
      v-if="dataLoading"
    />
  </q-page>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
export default {
  name: "OrdersTodays",
  components: {
    "order-table": require("components/cardTables/OrderCardTable.vue").default,
    "add-order-card": require("components/dialogCards/AddOrderCard.vue").default
  },
  data() {
    return {
      addOrder: false
    };
  },
  computed: {
    ...mapGetters("pharmaStore", [
      "getUser",
      "getOrdersAll",
      "dataLoading",
      "getOrdersUpToDate",
      "getPatientsUpToDate",
      "getCouriersUpToDate"
    ]),
    pharmacyId() {
      return this.getUser.pharmacy_id;
    }
  },
  methods: {
    ...mapActions("pharmaStore", [
      "loadOrderData",
      "loadPatients",
      "loadCouriers"
    ])
  },
  created() {
    if (!this.getOrdersUpToDate) this.loadOrderData(this.pharmacyId);
    if (!this.getPatientsUpToDate) this.loadPatients(this.getUser.pharmacy_id);
    if (!this.getCouriersUpToDate) this.loadCouriers(this.getUser.pharmacy_id);
  }
};
</script>

<style></style>
