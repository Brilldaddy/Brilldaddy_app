//frontend/pages/User/OrderDetails.js
import React, { useState, useEffect, useRef } from "react";
import { useParams } from "react-router-dom";
import axios from "axios";
import OrginalNavbar from "../../components/User/OrginalUserNavbar";
import NavbarWithMenu from "../../components/User/NavbarwithMenu";
import Footer from "../../components/User/Footer";
import { SERVER_URL } from "../../Constants";
import { useAppSelector } from '../../Redux/Store/store';
import {
  FaMapMarkerAlt,
  FaTimesCircle,
  FaCheckCircle,
  FaTruck,
  FaBoxOpen,
  FaClock,
  FaTruckMoving,
} from "react-icons/fa";
import ChatBotButton from "../../components/User/chatBot";
import ScrollToTopButton from "../../components/User/ScrollToTop";

import pdfMake from "pdfmake/build/pdfmake";
import pdfFonts from "pdfmake/build/vfs_fonts";

// Initialize pdfMake with fonts
if (typeof window !== 'undefined') {
  pdfMake.vfs = pdfFonts && pdfFonts.pdfMake ? pdfFonts.pdfMake.vfs : pdfFonts;
}

const formatCurrency = (value) => {
  if (value === undefined || value === null) return "";
  const [integerPart, decimalPart] = value.toString().split(".");
  const formattedInteger = integerPart.replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  return decimalPart ? `${formattedInteger}.${decimalPart}` : formattedInteger;
};

const OrderDetails = () => {
  const { id, productId } = useParams();
  const [order, setOrder] = useState(null);
  const [showCancelModal, setShowCancelModal] = useState(false);
  const [selectedReason, setSelectedReason] = useState("");
  const [imageUrls, setImageUrls] = useState({});
  const [isCancelButtonDisabled, setIsCancelButtonDisabled] = useState(false);
  const [isOrderCancelled, setIsOrderCancelled] = useState(false);
  const [showReturnModal, setShowReturnModal] = useState(false);
  const invoiceRef = useRef();
  const [otherReason, setOtherReason] = useState("");
  const [image, setImage] = useState(null);
  const [returnButtonDisabled, setReturnButtonDisabled] = useState(false);

  const user = useAppSelector((state) => state.user);
  const userId = user.id;

  const [bankDetails, setBankDetails] = useState({
    accountNumber: "",
    confirmAccountNumber: "",
    ifscCode: "",
    branch: "",
    accountHolderName: ""
  });

  const cancelReasons = [
    "Found a better price",
    "Order placed by mistake",
    "Delivery time too long",
    "Change of mind",
    "Other",
  ];

  const returnReasons = [
    "Damaged product",
    "Incorrect item received",
    "Item no longer needed",
    "Other",
  ];

  useEffect(() => {
    const fetchOrderDetails = async () => {
      try {
        console.log("reachinhhg");
        const response = await axios.get(`${SERVER_URL}/user/order/${id}`);
        console.log("Fetched order response:", response.data);

        const filteredOrder = {
          ...response.data,
          cartItems: response.data.cartItems.filter(
            (item) => item.productId._id === productId
          ),
        };
        console.log("Filtered order data:", filteredOrder);
        setOrder(filteredOrder);

        const imageUrlsMap = {};
        for (const item of filteredOrder.cartItems) {
          const imageId = item.productId.images[0];
          const imageResponse = await axios.get(
            `${SERVER_URL}/user/images/${imageId}`
          );
          imageUrlsMap[imageId] = imageResponse.data.imageUrl;
          console.log(
            `Image URL for product ${item.productId._id}:`,
            imageResponse.data.imageUrl
          );
        }
        setImageUrls(imageUrlsMap);
        // Ensure cancel button state persists across refreshes
        const isCancelled = response.data.status === "Cancelled";
        const isDelivered = response.data.status === "Delivered";
        setIsOrderCancelled(isCancelled);
        setIsCancelButtonDisabled(isCancelled);
        setIsCancelButtonDisabled(isCancelled || isDelivered);
        console.log("Final image URLs map:", imageUrlsMap);
      } catch (error) {
        console.error("Error fetching order details:", error);
      }
    };

    if (id && productId) fetchOrderDetails();
  }, [id, productId]);

  useEffect(() => {
    const orderTime = new Date(order?.orderDate);
    const currentTime = new Date();

    // Calculate milliseconds for 5 minutes
    const fiveMinutesInMilliseconds = 5 * 60 * 1000;

    if (order && currentTime - orderTime >= fiveMinutesInMilliseconds) {
      setIsCancelButtonDisabled(true);
    }
  }, [order]);

  

  const handleCancelOrder = () => {
    setShowCancelModal(true);
  };

  const handleBankDetailsChange = (e) => {
    const { name, value } = e.target;
    setBankDetails(prev => ({
      ...prev,
      [name]: value
    }));
  };


  const validateBankDetails = () => {
    if (bankDetails.accountNumber !== bankDetails.confirmAccountNumber) {
      alert("Account numbers do not match!");
      return false;
    }
    if (!bankDetails.accountNumber || !bankDetails.ifscCode || !bankDetails.branch || !bankDetails.accountHolderName) {
      alert("Please fill in all bank details!");
      return false;
    }
    return true;
  };

  const confirmCancelOrder = async () => {
    const productId = order.cartItems[0]?.productId._id; 

    try {
      const response = await axios.put(
        `${SERVER_URL}/admin/cancel-order/` + order._id,
        {
          userId: userId,
          orderId: order._id,
          productId: productId, // The product ID
          cancelReason:
            selectedReason === "Other"
              ? otherReason
              : selectedReason || "No reason specified",
              bankDetails: {
                accountNumber: bankDetails.accountNumber,
                ifscCode: bankDetails.ifscCode,
                branch: bankDetails.branch,
                accountHolderName: bankDetails.accountHolderName
              },
              orderDetails: {
                orderId: order._id,
                orderDate: order.orderDate,
                totalAmount: order.totalAmount
              }    
            }
      );

      console.log("Order cancelled successfully:", response.data);
      // Close the modal and handle any success actions
      setShowCancelModal(false);
      alert("Order has been cancelled.");
      setIsOrderCancelled(true);
      setIsCancelButtonDisabled(true);
    } catch (error) {
      console.error("Error cancelling order:", error);
      alert("Error cancelling order: " + error.message);
    }
  };

  const toggleReasonSelection = (reason) => {
    setSelectedReason((prevReason) => (prevReason === reason ? "" : reason));
    if (reason !== "Other") {
      setOtherReason("");
    }
    if (reason !== "Damaged product") {
      setImage(null);
    }
  };

  const handleOtherReasonChange = (event) => {
    const value = event.target.value;
    if (value.length <= 50) {
      setOtherReason(value);
    }
  };

  useEffect(() => {
    if (order && order.orderStatus === "Returned") {
      setReturnButtonDisabled(true);
    }
  }, [order]);

  const handleDownloadInvoice = () => {
    try{
    const items = order.cartItems.map((item) => [
      item.productId.name,
      item.productId.description,
      `₹${item.price.toFixed(2)}`,
      item.quantity,
      `₹${(item.price * item.quantity).toFixed(2)}`,
    ]);

    const totalAmount = order.cartItems
      .reduce((total, item) => total + item.price * item.quantity, 0)
      .toFixed(2);

    const documentDefinition = {
      content: [
        { text: "Invoice", style: "header", alignment: "center" },
        { text: `Order ID: ${id}`, style: "subheader" },
        { text: "Shipping Address:", style: "subheader" },
        {
          text: `${order.selectedAddressId.userName}, 
          ${order.selectedAddressId.addressLine}, 
          ${order.selectedAddressId.street}, ${order.selectedAddressId.state}, ${order.selectedAddressId.pincode}, 
          Phone: ${order.selectedAddressId.phoneNumber}`,
        },
        { text: "Order Details", style: "subheader", margin: [0, 10, 0, 10] },
        {
          table: {
            headerRows: 1,
            widths: ["*", "*", "auto", "auto", "auto"],
            body: [
              ["Product Name", "Description", "Price", "Quantity", "Total"],
              ...items,
              [
                { text: "Total Amount", colSpan: 4, alignment: "right" },
                {},
                {},
                {},
                `₹${totalAmount}`,
              ],
            ],
          },
        },
      ],
      styles: {
        header: { fontSize: 18, bold: true },
        subheader: { fontSize: 12, bold: true, margin: [0, 10, 0, 5] },
      },
    };

    pdfMake.createPdf(documentDefinition).download(`Order_${id}_Invoice.pdf`);
  }catch (error) {
    console.error('Error generating PDF:', error);
    alert('Error generating PDF. Please try again.');
  }
  };

  

  const handleReturnOrder = () => {
    setShowReturnModal(true);
  };

  const handleImageChange = (e) => {
    setImage(e.target.files[0]); // Save the uploaded image
  };

  const confirmReturnOrder = async () => {
    const userId = order.userId; // Get the userId from the order details or the current user's session
    const productId = order.cartItems[0]?.productId._id;

    try {
      const response = await axios.put(
        `${SERVER_URL}/admin/return-order/${order._id}`,
        {
          userId: userId,
          orderId: order._id,
          productId: productId, // The product ID
          selectedReason:
            selectedReason === "Other"
              ? otherReason
              : selectedReason || "No reason specified",
              bankDetails: {
                accountNumber: bankDetails.accountNumber,
                ifscCode: bankDetails.ifscCode,
                branch: bankDetails.branch,
                accountHolderName: bankDetails.accountHolderName
              },
              orderDetails: {
                orderId: order._id,
                orderDate: order.orderDate,
                totalAmount: order.totalAmount
              }    
        }
      );

      setShowReturnModal(false);
      setReturnButtonDisabled(true);
      alert("Order has been returned.");
    } catch (error) {
      console.error("Error returning order:", error);
      alert("Error returning order: " + error.message);
    }
  };

  if (!order) return <p>Loading...</p>;

  const totalAmount = order.cartItems
    .reduce((total, item) => {
      return total + item.price * item.quantity;
    }, 0)
    .toFixed(2);

  // Order status mapping
  const statusMapping = {
    Processing: 25,
    Shipped: 50,
    "Out for Delivery": 75,
    Delivered: 100,
    Cancelled: 100,
  };

  const productStatus = order?.cartItems[0]?.status;
  const progressPercentage =
    productStatus === "Cancelled" ? 0 : statusMapping[productStatus] || 0;
  const progressBarColor =
    productStatus === "Cancelled"
      ? "bg-red-600"
      : progressPercentage === 100
      ? "bg-green-600"
      : "bg-blue-600";
  const orderStatusText =
    productStatus === "Cancelled"
      ? "Cancelled"
      : productStatus === "Delivered"
      ? "Delivered"
      : productStatus === "Returned"
      ? "Returning"
      : "In Progress";

  // Updated icon logic based on order status
  const getStatusIcon = () => {
    if (productStatus === "Cancelled") {
      return <FaTimesCircle />;
    }
    return <FaCheckCircle />;
  };

  // Icon color logic based on order status
  const getIconColor = (status) => {
    const productStatus = order?.cartItems[0]?.status;
    if (productStatus === "Cancelled" || progressPercentage === 0) {
      return "text-red-600";
    } else if (status === "Processing" && progressPercentage >= 25) {
      return "text-green-600";
    } else if (status === "Shipped" && progressPercentage >= 50) {
      return "text-green-600";
    } else if (status === "Out for Delivery" && progressPercentage >= 75) {
      return "text-green-600";
    } else if (status === "Delivered" && progressPercentage === 100) {
      return "text-green-600";
    }
    return "text-gray-600";
  };

  const stepClasses = (step) => {
    const activeSteps = [
      "Processing",
      "Designing",
      "Shipped",
      "En Route",
      "Arrived",
    ];
    return `step ${
      activeSteps.includes(productStatus) &&
      activeSteps.indexOf(productStatus) >= activeSteps.indexOf(step)
        ? "active"
        : ""
    }`;
  };

  return (
    <div className="flex flex-col min-h-screen bg-gradient-to-b from-blue-300 to-white py-0 overflow-hidden">
      <OrginalNavbar />
      <NavbarWithMenu />

      <div className="max-w-6xl mx-auto p-4 md:p-8 grid grid-cols-1 md:grid-cols-2 gap-8">
        {/* Left Side: Address and More Actions */}
        <div className="bg-white p-6 rounded-lg shadow-xl">
          <h3 className="text-2xl font-semibold mb-6 text-gray-800">
            Shipping Address
          </h3>
          {order?.selectedAddressId ? (
            <div className="space-y-3">
              <p className="text-lg font-medium text-gray-700">
                {order.selectedAddressId.userName}
              </p>
              <p className="text-gray-600">
                {order.selectedAddressId.addressLine}
              </p>
              <p className="text-gray-600">
                {order.selectedAddressId.street},{" "}
                {order.selectedAddressId.state},{" "}
                {order.selectedAddressId.pincode}
              </p>
              <p className="text-gray-600">
                {order.selectedAddressId.flatNumber}
              </p>
              <p className="text-gray-600">
                Phone: {order.selectedAddressId.phoneNumber}
              </p>
            </div>
          ) : (
            <p className="text-gray-600">
              Address information is not available.
            </p>
          )}

          <hr className="my-6 border-gray-200" />

          <h4 className="text-xl font-semibold mb-4 text-gray-800">
            More Actions
          </h4>
          <div className="flex flex-col space-y-3">
            <button
              onClick={handleDownloadInvoice}
              className="px-6 py-3 bg-blue-600 text-white rounded-lg shadow hover:bg-blue-700 transition-all duration-300"
            >
              Download Invoice
            </button>
            {/* Cancel Order button */}
            {productStatus !== "Delivered" && productStatus !== "Returned" && (
              <button
                onClick={handleCancelOrder}
                disabled={
                  isCancelButtonDisabled || productStatus === "Cancelled"
                }
                className={`w-full py-2 px-4 text-white font-semibold rounded-lg ${
                  isCancelButtonDisabled || productStatus === "Cancelled"
                    ? "bg-gray-500 cursor-not-allowed"
                    : "bg-red-600 hover:bg-red-800"
                }`}
              >
                {productStatus === "Cancelled"
                  ? "Order Cancelled"
                  : "Cancel Order"}
              </button>
            )}

            {/* Return Order button */}
            {productStatus === "Delivered" || productStatus === "Returned" ? (
              <button
                onClick={handleReturnOrder}
                disabled={returnButtonDisabled}
                className={`px-4 py-2 rounded-md ${
                  returnButtonDisabled
                    ? "bg-gray-400 cursor-not-allowed"
                    : "bg-yellow-600 text-white hover:bg-yelloe-800"
                }`}
              >
                {order.orderStatus === "Returned"
                  ? "Order Returned"
                  : "Return Order"}
              </button>
            ) : null}
          </div>
        </div>

        {/* Right Side: Product Details and Progress Bar */}
        <div className="bg-white p-6 rounded-lg shadow-lg">
          <div className="text-gray-700 text-sm font-semibold mb-4">
            Order Date: {new Date(order.orderDate).toLocaleDateString()}
          </div>

          {/* Product Details */}
          {order.cartItems.map((item) => (
            <div
              key={item.productId._id}
              className="flex flex-col items-center md:items-start md:flex-row mb-4"
            >
              <img
                src={imageUrls[item.productId.images[0]]}
                alt={item.productId.name}
                className="w-32 h-32 object-cover rounded-lg mb-4 md:mb-0 md:mr-4"
              />
              <div className="flex flex-col w-full">
                <h5 className="text-lg font-bold">{item.productId.name}</h5>
                <p className="text-gray-600">{item.productId.description}</p>
                <div className="flex justify-between w-full mt-2">
                  <span className="text-gray-700">
                    Price: ₹{formatCurrency(item.price)}
                  </span>
                  <span className="text-gray-700">
                    Quantity: {item.quantity}
                  </span>
                  <span className="text-gray-700">
                    Total: ₹{formatCurrency(item.price * item.quantity)}
                  </span>
                </div>
              </div>
            </div>
          ))}

          <hr className="my-6 border-gray-300" />

          {/* Order Status and Progress Bar */}
          <div className="mb-4">
            {/* Title with Icon */}
            <div className="flex items-center space-x-2 mb-4">
              <FaMapMarkerAlt className="text-blue-600" size={20} />
              <h4 className="text-lg font-semibold">Order Status</h4>
            </div>

            {/* Status Icons and Progress Bar */}
            <div className="px-4 py-6 md:px-8 flex flex-col items-center">
              {/* Icons Section */}
              <div className="flex flex-row items-center justify-between w-full space-x-2 md:space-x-20 mb-4">
                {/* Each Icon */}
                <div className="flex flex-col items-center text-sm">
                  <div className={`text-2xl ${getIconColor("Processing")}`}>
                    <FaClock />
                  </div>
                  <p className="mt-1">Processing</p>
                </div>
                <div className="flex flex-col items-center text-sm">
                  <div className={`text-2xl ${getIconColor("Shipped")}`}>
                    <FaTruck />
                  </div>
                  <p className="mt-1">Shipped</p>
                </div>
                <div className="flex flex-col items-center text-sm">
                  <div
                    className={`text-2xl ${getIconColor("Out for Delivery")}`}
                  >
                    <FaTruckMoving />
                  </div>
                  <p className="mt-1">Out for Delivery</p>
                </div>
                <div className="flex flex-col items-center text-sm">
                  <div className={`text-2xl ${getIconColor("Delivered")}`}>
                    {getStatusIcon()}
                  </div>
                  <p className="mt-1">Delivered</p>
                </div>
              </div>

              {/* Progress Bar */}
              <div className="flex flex-col items-center mb-4 w-full">
                <div className="bg-gray-200 w-full h-4 rounded-full overflow-hidden">
                  <div
                    className={`h-full ${progressBarColor} transition-all duration-300`}
                    style={{ width: `${progressPercentage}%` }}
                  />
                </div>
                <p className="text-sm md:text-lg font-semibold mt-2">
                  Status: {orderStatusText}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Cancel Modal */}
      {showCancelModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
          <div className="bg-white p-6 rounded-lg shadow-xl w-96 max-h-[90vh] overflow-y-auto">
            <h2 className="text-xl font-bold mb-4">Cancel Order</h2>
            
            {/* Cancellation Reason */}
            <div className="mb-4">
              <p className="font-semibold mb-2">Select Reason:</p>
              {cancelReasons.map((reason) => (
                <div key={reason} className="mb-2">
                  <input
                    type="radio"
                    id={reason}
                    name="cancelReason"
                    value={reason}
                    checked={selectedReason === reason}
                    onChange={(e) => setSelectedReason(e.target.value)}
                    className="mr-2"
                  />
                  <label htmlFor={reason}>{reason}</label>
                </div>
              ))}
              {selectedReason === "Other" && (
                <textarea
                  value={otherReason}
                  onChange={(e) => setOtherReason(e.target.value)}
                  className="w-full p-2 border rounded"
                  placeholder="Please specify your reason"
                />
              )}
            </div>

            {/* Bank Details Form */}
            <div className="space-y-3">
              <h3 className="font-semibold">Bank Details for Refund</h3>
              
              <div>
                <label className="block text-sm">Account Number</label>
                <input
                  type="text"
                  name="accountNumber"
                  value={bankDetails.accountNumber}
                  onChange={handleBankDetailsChange}
                  className="w-full p-2 border rounded"
                />
              </div>

              <div>
                <label className="block text-sm">Confirm Account Number</label>
                <input
                  type="text"
                  name="confirmAccountNumber"
                  value={bankDetails.confirmAccountNumber}
                  onChange={handleBankDetailsChange}
                  className="w-full p-2 border rounded"
                />
              </div>

              <div>
                <label className="block text-sm">IFSC Code</label>
                <input
                  type="text"
                  name="ifscCode"
                  value={bankDetails.ifscCode}
                  onChange={handleBankDetailsChange}
                  className="w-full p-2 border rounded"
                />
              </div>

              <div>
                <label className="block text-sm">Branch</label>
                <input
                  type="text"
                  name="branch"
                  value={bankDetails.branch}
                  onChange={handleBankDetailsChange}
                  className="w-full p-2 border rounded"
                />
              </div>

              <div>
                <label className="block text-sm">Account Holder Name</label>
                <input
                  type="text"
                  name="accountHolderName"
                  value={bankDetails.accountHolderName}
                  onChange={handleBankDetailsChange}
                  className="w-full p-2 border rounded"
                />
              </div>
            </div>

            <div className="flex justify-end space-x-4 mt-6">
              <button
                onClick={() => setShowCancelModal(false)}
                className="px-4 py-2 bg-gray-300 rounded"
              >
                Close
              </button>
              <button
                onClick={confirmCancelOrder}
                className="px-4 py-2 bg-red-600 text-white rounded"
              >
                Confirm Cancel
              </button>
            </div>
          </div>
        </div>
      )}

{showReturnModal && (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50">
      <div className="bg-white p-6 rounded-lg shadow-xl w-[480px] max-h-[90vh] overflow-y-auto">
        <h3 className="text-xl font-semibold text-gray-800 mb-4">
          Return Order Request
        </h3>
        
        {/* Return Reasons */}
        <div className="mb-6">
          <h4 className="font-semibold mb-2">Select Return Reason:</h4>
          <div className="space-y-2">
            {returnReasons.map((reason) => (
              <button
                key={reason}
                onClick={() => toggleReasonSelection(reason)}
                className={`block w-full text-left px-4 py-2 rounded-lg ${
                  selectedReason === reason
                    ? "bg-blue-500 text-white"
                    : "bg-gray-100 text-gray-700"
                }`}
              >
                {reason}
              </button>
            ))}
          </div>
          
          {selectedReason === "Other" && (
            <input
              type="text"
              placeholder="Other reason"
              value={otherReason}
              onChange={handleOtherReasonChange}
              className="w-full p-2 border rounded-lg mt-2"
            />
          )}
        </div>

        {/* Bank Details Form */}
        <div className="space-y-4 mb-6">
          <h4 className="font-semibold">Bank Details for Refund</h4>
          
          <div>
            <label className="block text-sm mb-1">Account Number</label>
            <input
              type="text"
              name="accountNumber"
              value={bankDetails.accountNumber}
              onChange={handleBankDetailsChange}
              className="w-full p-2 border rounded"
            />
          </div>

          <div>
            <label className="block text-sm mb-1">Confirm Account Number</label>
            <input
              type="text"
              name="confirmAccountNumber"
              value={bankDetails.confirmAccountNumber}
              onChange={handleBankDetailsChange}
              className="w-full p-2 border rounded"
            />
          </div>

          <div>
            <label className="block text-sm mb-1">IFSC Code</label>
            <input
              type="text"
              name="ifscCode"
              value={bankDetails.ifscCode}
              onChange={handleBankDetailsChange}
              className="w-full p-2 border rounded"
            />
          </div>

          <div>
            <label className="block text-sm mb-1">Branch</label>
            <input
              type="text"
              name="branch"
              value={bankDetails.branch}
              onChange={handleBankDetailsChange}
              className="w-full p-2 border rounded"
            />
          </div>

          <div>
            <label className="block text-sm mb-1">Account Holder Name</label>
            <input
              type="text"
              name="accountHolderName"
              value={bankDetails.accountHolderName}
              onChange={handleBankDetailsChange}
              className="w-full p-2 border rounded"
            />
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex justify-end space-x-4">
          <button
            onClick={() => setShowReturnModal(false)}
            className="px-6 py-2 bg-gray-300 text-black rounded-lg"
          >
            Cancel
          </button>
          <button
            onClick={confirmReturnOrder}
            className="px-6 py-2 bg-green-500 text-white rounded-lg"
          >
            Submit Return Request
          </button>
        </div>
      </div>
    </div>
  )}
      <Footer />
      <ScrollToTopButton/>
      {/* <div className="fixed bottom-8 right-8 z-50">
        <ChatBotButton />
      </div> */}
    </div>
  );
};

export default OrderDetails;
